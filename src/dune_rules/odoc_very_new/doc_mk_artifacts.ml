open Import
open Memo.O
open Doc_pkgs
open Doc_index
open Doc_index_tree
(* let index_info_of_pkg _ _ _ = failwith "TODO" *)
(* let index_info_of_lib _ _ _ = failwith "TODO" *)
(* let index_info_of_external_fallback _ _ _ = failwith "TODO" *)

let lib_artifacts ctx index lib modules =
  let info = Lib.info lib in
  let cm_kind : Lib_mode.Cm_kind.t =
    match
      let modes = Lib_info.modes info in
      Lib_mode.Map.Set.for_merlin modes
    with
    | Ocaml _ -> Ocaml Cmi
    | Melange -> Melange Cmi
  in
  let obj_dir = Lib_info.obj_dir info in
  let entry_modules = Modules.With_vlib.entry_modules modules in
  modules
  |> Modules.With_vlib.drop_vlib
  |> Modules.fold ~init:[] ~f:(fun m acc ->
    let visible =
      let visible =
        List.mem entry_modules m ~equal:(fun m1 m2 ->
          Module_name.equal (Module.name m1) (Module.name m2))
      in
      visible
      && Module.name m
         |> Module_name.to_string
         |> String.contains_double_underscore
         |> not
    in
    let cmti_file = Obj_dir.Module.cmti_file obj_dir ~cm_kind m in
    Doc_artifact.make_module ctx index cmti_file ~visible :: acc)
;;

let index_info_of_lib_def =
  let module Input = struct
    module Super_context = Super_context.As_memo_key

    type t = Super_context.t * bool * Lib.t

    let equal (c1, b1, l1) (c2, b2, l2) =
      Super_context.equal c1 c2 && b1 = b2 && Lib.equal l1 l2
    ;;

    let hash (c, b, l) = Poly.hash (Super_context.hash c, b, Lib.hash l)
    let to_dyn (c, b, l) = Dyn.Tuple [ Super_context.to_dyn c; Dyn.Bool b; Lib.to_dyn l ]
  end
  in
  let f : Input.t -> _ =
    fun (sctx, all, lib) ->
    let ctx = Super_context.context sctx in
    let* maps = Valid.libs_maps ctx ~all in
    let index =
      match Lib.Local.of_lib lib with
      | Some l -> Index.of_local_lib l
      | None -> Index.of_external_lib maps lib
    in
    let+ artifacts =
      let+ modules = Dir_contents.modules_of_lib sctx (lib :> Lib.t) in
      match modules with
      | Some m -> lib_artifacts ctx index (lib :> Lib.t) m
      | None ->
        (* Note this shouldn't happen as we've filtered out libs
           without a [Modules.t] in the classification stage. *)
        Log.info
          [ Pp.textf
              "Expecting modules info for library %s"
              (Lib.name lib |> Lib_name.to_string)
          ];
        []
    in
    let libs =
      let entry_modules =
        artifacts
        |> List.filter ~f:Doc_artifact.is_module
        |> List.filter ~f:Doc_artifact.is_visible
      in
      Lib.Map.singleton lib entry_modules
    in
    let package = Lib_info.package (Lib.info lib) in
    let lib_index_info =
      ( index
      , { Index_tree.libs
        ; artifact_sets = [ { artifacts; compile_libs = [ lib ] } ]
        ; predefined_index = None
        ; package
        ; is_fallback = false
        } )
    in
    match package with
    | None -> [ lib_index_info ]
    | Some pkg ->
      let pkg_index = Index.of_pkg maps pkg in
      let pkg_index_info =
        ( pkg_index
        , { Index_tree.libs
          ; artifact_sets = []
          ; predefined_index = None
          ; package = Some pkg
          ; is_fallback = false
          } )
      in
      [ lib_index_info; pkg_index_info ]
  in
  Memo.create "index_info_of_lib" ~input:(module Input) f
;;

let index_info_of_lib sctx all lib = Memo.exec index_info_of_lib_def (sctx, all, lib)

(* Read an _external_ directory and find all the 'odoc-interesting' files
   inside. This is used in the fallback case where we don't know what modules
   there are in a particular switch directory. *)
let modules_of_dir d : (Module_name.t * (Path.t * [ `Cmti | `Cmt | `Cmi ])) list Memo.t =
  let extensions = [ ".cmti", `Cmti; ".cmt", `Cmt; ".cmi", `Cmi ] in
  Fs_memo.dir_contents (Path.as_outside_build_dir_exn d)
  >>| function
  | Error _ -> []
  | Ok dc ->
    let list = Fs_cache.Dir_contents.to_list dc in
    List.filter_map list ~f:(fun (x, ty) ->
      match ty, List.assoc extensions (Filename.extension x) with
      | Unix.S_REG, Some _ -> Some (Filename.remove_extension x)
      | _, _ -> None)
    |> List.sort_uniq ~compare:String.compare
    |> List.map ~f:(fun m ->
      let ext, ty =
        List.find_exn extensions ~f:(fun (ext, _ty) ->
          List.exists list ~f:(fun (n, _) -> n = m ^ ext))
      in
      Module_name.of_string m, (Path.relative d (m ^ ext), ty))
;;

(* Here we are constructing the list of artifacts for various types of things
   to be documented - packages, fallback dirs, libraries (both private and those
   in packages) *)
let fallback_artifacts
  ctx
  (location : Dune_package.External_location.t)
  (libs : Lib.t Lib_name.Map.t)
  =
  let* maps = Valid.libs_maps ctx ~all:true in
  match Index.of_external_loc maps location with
  | None -> Memo.return []
  | Some index ->
    let+ mods =
      let* ocaml = Context.ocaml ctx in
      let stdlib_dir = ocaml.lib_config.Lib_config.stdlib_dir in
      let cmti_path =
        match location with
        | Absolute d -> d
        | Relative_to_findlib (dir, l) -> Path.relative dir (Path.Local.to_string l)
        | Relative_to_stdlib l -> Path.relative stdlib_dir (Path.Local.to_string l)
      in
      modules_of_dir cmti_path
      >>| List.map ~f:(fun (mod_name, (cmti_file, _)) ->
        let visible =
          Module_name.to_string mod_name |> String.contains_double_underscore |> not
        in
        Doc_artifact.make_module ctx index cmti_file ~visible)
    in
    [ mods, libs ]
;;

let index_info_of_external_fallback_def =
  let f (ctx, location, (fallback : Classify.fallback)) =
    let* maps = Valid.libs_maps ctx ~all:true in
    match Index.of_external_loc maps location with
    | None -> Memo.return []
    | Some index ->
      Valid.filter_fallback_libs ctx ~all:true fallback.libs
      >>= fallback_artifacts ctx location
      >>| List.map ~f:(fun (artifacts, libs) ->
        (* Urgh grotty hack time. The [ocaml] dir contains the [threads] library, which
           actually has no implementation and merely depends upon either [threads.vm]
           or [threads.posix], both of which are found as subdirectories. These libraries
           are in separate directories and, in turn, depend upon [unix], which is found in
           the [ocaml] directory. Since we only do fine-grained dependencies _between_
           directories this means that the [ocaml] dir depends on the [threads] dir, and
           the [threads] dir depends on the [ocaml] dir. We remove this dependency cycle
           by pretending the [threads] library is not present in the [ocaml] dir. This
           works because there actually aren't any modules in the [threads] library itself,
           they're all in the subdirs. *)
        let libs =
          if Lib_name.Map.mem libs (Lib_name.of_string "stdlib")
          then
            Lib_name.Map.filter libs ~f:(fun lib ->
              Lib.name lib |> Lib_name.to_string <> "threads")
          else libs
        in
        let compile_libs = Lib_name.Map.to_list_map libs ~f:(fun _ l -> l) in
        let libs =
          Lib_name.Map.fold libs ~init:Lib.Map.empty ~f:(fun lib map ->
            match Lib.Map.add map lib [] with
            | Ok map -> map
            | Error _ -> map)
        in
        ( index
        , { Index_tree.artifact_sets = [ { artifacts; compile_libs } ]
          ; libs
          ; predefined_index = None
          ; package = None
          ; is_fallback = true
          } ))
  in
  let module Local = struct
    module Super_context = Super_context.As_memo_key

    type t = Context.t * Dune_package.External_location.t * Classify.fallback

    let equal (sctx1, l1, f1) (sctx2, l2, f2) =
      Context.equal sctx1 sctx2
      && Dune_package.External_location.compare l1 l2 = Eq
      && Classify.fallback_equal f1 f2
    ;;

    let hash =
      Tuple.T3.hash
        Context.hash
        Dune_package.External_location.hash
        Classify.fallback_hash
    ;;

    let to_dyn (sctx, l1, f) =
      Dyn.Tuple
        [ Context.to_dyn sctx
        ; Dune_package.External_location.to_dyn l1
        ; Classify.fallback_to_dyn f
        ]
    ;;
  end
  in
  Memo.create "index_info_of_external_fallback" ~input:(module Local) f
;;

let index_info_of_external_fallback sctx location fallback =
  Memo.exec index_info_of_external_fallback_def (sctx, location, fallback)
;;

(* Here we construct the tree of all items that will end up being documented. *)
let full_tree sctx ~all =
  let ctx = Super_context.context sctx in
  let* categorized = Valid.get_categorized ctx all in
  Memo.return []
  |> fun init ->
  Package.Name.Set.fold categorized.Doc_pkgs.Valid.packages ~init ~f:(fun pkg acc ->
    let* acc = acc in
    let+ ii = Doc_index_tree.index_info_of_pkg sctx all pkg in
    List.rev_append ii acc)
  |> fun init ->
  Lib_name.Map.fold ~init categorized.local ~f:(fun lib acc ->
    let* acc = acc in
    let+ ii = index_info_of_lib sctx all (lib :> Lib.t) in
    List.rev_append ii acc)
  |> fun init ->
  Ext_loc_map.foldi ~init categorized.externals ~f:(fun loc ty acc ->
    let* acc = acc in
    match ty with
    | Dune_with_modules (_, lib) ->
      let+ ii = index_info_of_lib sctx all lib in
      List.rev_append ii acc
    | Fallback fallback ->
      let+ ii =
        index_info_of_external_fallback (Super_context.context sctx) loc fallback
      in
      List.rev_append ii acc
    | Nothing -> Memo.return acc)
;;
