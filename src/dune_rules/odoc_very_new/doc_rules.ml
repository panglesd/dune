open Import
open Memo.O
module Gen_rules = Build_config.Gen_rules
open Doc_index
open Doc_index_tree

let lib_equal l1 l2 = Lib.compare l1 l2 |> Ordering.is_eq

module Dep : sig
  (** [html_alias ctx target] returns the alias that depends on all html targets
      produced by odoc for [target] *)
  val html_alias : Path.Build.t -> Alias.t

  (** [deps ctx all maps valid_libs pkg requires] returns all odoc
      dependencies of [requires]. If a package [pkg] is also specified, then
      the odoc dependencies of the package are returned - these are the odoc
      files representing mld files in the package. [maps] is obtained via
      [Valid.libs_maps] and [valid_libs] comes from [Valid.get]. *)
  val deps
    :  Context.t
    -> Doc_pkgs.ext_loc_maps
    -> Lib.t list
    -> Package.Name.t option
    -> Lib.t list Resolve.t
    -> unit Action_builder.t

  (*** [setup_deps ctx all index odocs] Adds [odocs] as dependencies for [index].
    These dependencies may be used using the [deps] function *)
  val setup_deps : Context.t -> Index.t -> Path.Set.t -> unit Memo.t
end = struct
  let html_alias dir = Alias.make Alias0.doc_very_new ~dir
  let alias = Alias.make (Alias.Name.of_string ".odoc-all")

  let deps ctx maps valid_libs pkg requires =
    let open Action_builder.O in
    let* libs = Resolve.read requires in
    Action_builder.deps
      (let libs, init =
         match pkg with
         | None -> libs, Dep.Set.empty
         | Some p ->
           let index = Index.of_pkg maps p in
           let init =
             Dep.Set.singleton (Dep.alias (alias ~dir:(Index.odoc_dir ctx index)))
           in
           let pkg_libs =
             List.filter ~f:(fun l -> Lib.info l |> Lib_info.package = pkg) valid_libs
           in
           List.rev_append pkg_libs libs, init
       in
       List.fold_left libs ~init ~f:(fun acc (lib : Lib.t) ->
         match List.mem ~equal:lib_equal valid_libs lib with
         | false -> acc
         | true ->
           let index =
             match Lib.Local.of_lib lib with
             | None -> Index.of_external_lib maps lib
             | Some l -> Index.of_local_lib l
           in
           let dir = Index.odoc_dir ctx index in
           let alias = alias ~dir in
           Dep.Set.add acc (Dep.alias alias)))
  ;;

  let alias ctx index = alias ~dir:(Index.odoc_dir ctx index)

  let setup_deps ctx m files =
    Rules.Produce.Alias.add_deps (alias ctx m) (Action_builder.path_set files)
  ;;
end

let add_rule sctx =
  let dir = Context.build_dir (Super_context.context sctx) in
  Super_context.add_rule sctx ~dir
;;

let toplevel_index_contents (* t *) () =
  let b = Buffer.create 1024 in
  Printf.bprintf b "{0 Docs}\n\n";
  (* let all_descendents = Index_tree.fold ~init:[] ~f:(fun idx _ acc -> idx :: acc) t in *)
  (* let sorted = *)
  (*   List.sort *)
  (*     ~compare:(fun x y -> Dyn.compare (Index.to_dyn x) (Index.to_dyn y)) *)
  (*     all_descendents *)
  (* in *)
  (* let output_indices label = function *)
  (*   | [] -> () *)
  (*   | indices -> *)
  (*     Printf.bprintf b "{1 %s}\n" label; *)
  (*     List.iter indices ~f:(fun i -> *)
  (*       Printf.bprintf b "- {!page-\"%s\"}\n" (Index.mld_name_ty i)) *)
  (* in *)
  (* output_indices *)
  (*   "Local Packages" *)
  (*   (List.filter_map sorted ~f:(function *)
  (*     | [ x; Index.Top_dir Local_packages ] -> Some x *)
  (*     | _ -> None)); *)
  (* output_indices *)
  (*   "Switch-installed packages" *)
  (*   (List.filter_map sorted ~f:(function *)
  (*     | [ x; Index.Top_dir (Relative_to_findlib _) ] -> Some x *)
  (*     | [ (Index.Top_dir Relative_to_stdlib as x) ] -> Some x *)
  (*     | _ -> None)); *)
  (* output_indices *)
  (*   "Private libraries" *)
  (*   (List.filter_map sorted ~f:(function *)
  (*     | [ (Index.Private_lib _ as x) ] -> Some x *)
  (*     | _ -> None)); *)
  Buffer.contents b
;;

let default_index index tree _entry_modules =
  let (* Index_tree.Br *) info (* , children *) = tree in
  let b = Buffer.create 512 in
  let main_name, subtitle =
    match index with
    | [] -> "Main index", None (* unused! *)
    | [ Index.Top_dir (Relative_to_findlib (_, dir)) ] ->
      "Opam index", Some (sprintf "Packages installed in %s" (Path.to_string dir))
    | [ Index.Top_dir Relative_to_stdlib ] -> "Packages located relative to stdlib", None
    | [ Index.Top_dir Local_packages ] -> "Local packages", None
    | [ Index.Private_lib l ] -> sprintf "Private library %s" l, None
    | xs ->
      let subdirs =
        List.filter_map
          ~f:(fun x ->
            match x with
            | Index.Sub_dir x -> Some x
            | _ -> None)
          xs
      in
      if info.Index_tree.is_fallback
      then sprintf "Directory %s" (String.concat ~sep:"/" (List.rev subdirs)), None
      else sprintf "Package %s" (String.concat ~sep:"." (List.rev subdirs)), None
  in
  Printf.bprintf b "{0 %s}\n" main_name;
  (match subtitle with
   | None -> ()
   | Some s -> Printf.bprintf b "{i %s}\n" s);
  (* let subindexes = List.map children ~f:(fun (ty, _) -> ty :: index) in *)
  (* if List.length children > 0 *)
  (* then ( *)
  (*   Printf.bprintf b "{1 Sub-indexes}\n%!"; *)
  (*   subindexes *)
  (*   |> List.sort ~compare:(fun x y -> Dyn.compare (Index.to_dyn x) (Index.to_dyn y)) *)
  (*   |> List.iter ~f:(fun i -> *)
  (*     Printf.bprintf b "- {{!page-\"%s\"} %s}\n" (Index.mld_name i) (Index.mld_name i))); *)
  (* if info.is_fallback *)
  (* then fallback_index_contents b entry_modules (Index_tree.all_artifacts info) *)
  (* else standard_index_contents b entry_modules; *)
  Buffer.contents b
;;

(* Here are the rules that operate on the Index_tree, for compiling and linking
   indexes, compiling and linking the artifacts of a package/library/fallback dir,
   and for generating the resulting HTML. *)

(* A parent is always an index. Here we operate on the parent as an artifact
   to find the arguments to odoc. *)
let parent_id ctx a =
  let parent_id = Doc_artifact.odoc_parent_id a in
  [ Command.Args.A "--output-dir"; Path (Path.build (Index.odoc_root ctx)) ]
  @
  let parent_id = parent_id |> Odoc_parent_id.to_string in
  [ Command.Args.A "--parent-id"; A parent_id ]
;;

let compile_mld sctx a ~quiet =
  assert (Doc_artifact.artifact_ty a = Doc_artifact.Mld);
  let ctx = Super_context.context sctx in
  let odoc_file = Doc_artifact.odoc_file ctx a in
  let run_odoc =
    let quiet_arg =
      if quiet then Command.Args.A "--print-warnings=false" else Command.Args.empty
    in
    let doc_dir = Path.Build.parent_exn (Doc_artifact.odoc_file ctx a) in
    let odoc_input = Doc_artifact.source_file a in
    let ctx = Super_context.context sctx in
    let parent_id = parent_id ctx a in
    Odoc.run_odoc
      sctx
      ~dir:(Path.build doc_dir)
      "compile"
      ~flags_for:(Some odoc_file)
      ~quiet
      (Command.Args.A "-o" :: Target odoc_file :: Dep odoc_input :: quiet_arg :: parent_id)
  in
  let+ () = add_rule sctx run_odoc in
  odoc_file
;;

let link_requires stdlib_opt libs =
  Lib.closure libs ~linking:false
  |> Resolve.Memo.map ~f:(fun libs ->
    match stdlib_opt with
    | None -> libs
    | Some stdlib -> stdlib :: libs)
;;

open Doc_pkgs

(* Given a list of dependency libraries, construct the command line options
   to odoc to use them. *)
let odoc_include_flags ctx maps pkg requires indices =
  Resolve.args
  @@
  let open Resolve.O in
  let+ paths =
    let+ paths =
      let+ paths =
        requires
        >>| List.fold_left ~init:Path.Set.empty ~f:(fun paths lib ->
          let index =
            match Lib.Local.of_lib lib with
            | None -> Index.of_external_lib maps lib
            | Some lib -> Index.of_local_lib lib
          in
          Index.odoc_dir ctx index |> Path.build |> Path.Set.add paths)
      in
      match pkg with
      | None -> paths
      | Some p ->
        Index.odoc_dir ctx (Index.of_local_package p) |> Path.build |> Path.Set.add paths
    in
    List.fold_left indices ~init:paths ~f:(fun p index ->
      let odoc_dir = Doc_artifact.odoc_file ctx index |> Path.Build.parent_exn in
      Path.Set.add p (Path.build odoc_dir))
  in
  Command.Args.S
    (Path.Set.to_list paths
     |> List.concat_map ~f:(fun dir -> [ Command.Args.A "-I"; Path dir ]))
;;

(* Create a dependency on the odoc file of an index *)
let index_dep ctx index =
  Doc_artifact.odoc_file ctx index
  |> Path.build
  |> Dune_engine.Dep.file
  |> Dune_engine.Dep.Set.singleton
;;

(* Link a _set_ of odoc files into odocl files. *)
let link_odoc_rules
  sctx
  ~all
  (artifacts : Doc_artifact.t list)
  ~quiet
  ~package
  ~libs
  ~indices
  =
  let ctx = Super_context.context sctx in
  let* maps = Doc_pkgs.Valid.libs_maps ctx ~all in
  let* requires =
    let* stdlib_opt = Doc_pkgs.stdlib_lib (Context.name ctx) in
    link_requires stdlib_opt libs
  in
  let* deps =
    let+ valid_libs, _ = Valid.get ctx ~all in
    Dep.deps ctx maps valid_libs package requires
  in
  let index_deps =
    List.map indices ~f:(fun x -> Command.Args.Hidden_deps (index_dep ctx x))
  in
  let quiet_arg =
    if quiet then Command.Args.A "--print-warnings=false" else Command.Args.empty
  in
  Memo.parallel_iter artifacts ~f:(fun a ->
    let run_odoc =
      Odoc.run_odoc
        sctx
        ~dir:(Path.parent_exn (Path.build (Doc_artifact.odocl_file ctx a)))
        "link"
        ~quiet
        ~flags_for:(Some (Doc_artifact.odoc_file ctx a))
        (index_deps
         @ [ odoc_include_flags ctx maps package requires indices
           ; A "-o"
           ; Target (Doc_artifact.odocl_file ctx a)
           ; Dep (Path.build (Doc_artifact.odoc_file ctx a))
           ]
         @ [ quiet_arg ])
    in
    add_rule
      sctx
      (let open Action_builder.With_targets.O in
       Action_builder.with_no_targets deps >>> run_odoc))
;;

open Doc_path

(* Output the actual html *)
let html_generate sctx ~search_db (a : Doc_artifact.t) =
  let ctx = Super_context.context sctx in
  let html_output = Paths.html_root ctx in
  let support_relative =
    let odoc_support_path = Paths.odoc_support ctx in
    Path.reach (Path.build odoc_support_path) ~from:(Path.build html_output)
  in
  let search_args =
    Sherlodoc.odoc_args sctx ~search_db ~dir_sherlodoc_dot_js:(Index.html_dir ctx [])
  in
  let run_odoc =
    Odoc.run_odoc
      sctx
      ~quiet:false
      ~dir:(Path.build html_output)
      "html-generate"
      ~flags_for:None
      [ Command.Args.A "-o"
      ; Path (Path.build html_output)
      ; search_args
      ; A "--support-uri"
      ; A support_relative
      ; A "--theme-uri"
      ; A support_relative
      ; Dep (Path.build (Doc_artifact.odocl_file ctx a))
      ]
  in
  let rule, result =
    match Doc_artifact.artifact_ty a with
    | Mld ->
      ( Action_builder.With_targets.add ~file_targets:[ Doc_artifact.html_file a ] run_odoc
      , None )
    | Module _ ->
      let dir = Doc_artifact.html_dir a in
      ( Action_builder.With_targets.add_directories ~directory_targets:[ dir ] run_odoc
      , Some dir )
  in
  let+ () = add_rule sctx rule in
  result
;;

let hierarchical_index_rules sctx ~all (tree : (Index.t * Index_tree.info) list) =
  let ctx = Super_context.context sctx in
  let inner index ((* Index_tree.Br *) (ii : Index_tree.info (* , children *)) as t) =
    let mld = Doc_artifact.index ctx index in
    let quiet = false in
    let* () =
      let index_path = Index.mld_path ctx index in
      match ii.predefined_index with
      | Some p -> add_rule sctx (Action_builder.symlink ~src:p ~dst:index_path)
      | None ->
        let content =
          match index with
          | [] -> toplevel_index_contents (* tree *) ()
          | _ ->
            Lib.Map.foldi ~init:[] ~f:(fun l x acc -> (Lib.name l, x) :: acc) ii.libs
            |> default_index index t
        in
        add_rule sctx (Action_builder.write_file index_path content)
    and* (_ : Path.Build.t) = compile_mld sctx mld ~quiet
    and* () =
      let libs = Lib.Map.keys ii.libs in
      let package = ii.package in
      (* let all_descendent_artifacts = *)
      (*   let all_descendent_indices = *)
      (*     (\* This is down to an odoc deficiency. We should remove this restriction *)
      (*        once we can reference page children in odoc ref syntax. The problem *)
      (*        here is that we'd like to be able to reference [{!page-pkg.page-sublib}] *)
      (*        but we can't, we can only reference [{!page-sublib}] which means there's *)
      (*        a danger of a clash if we have, say, library [odoc.odoc]. *\) *)
      (*     let cur_depth = List.length index in *)
      (*     Index_tree.fold t ~init:[] ~f:(fun idx _ acc -> *)
      (*       if List.length idx > cur_depth + 2 then acc else (idx @ index) :: acc) *)
      (*     (\* First descendent is actually this node. Remove it! *\) *)
      (*     |> List.rev *)
      (*     |> List.tl *)
      (*   in *)
      (*   List.map all_descendent_indices ~f:(Doc_artifact.index ctx) *)
      (* in *)
      let all_artifacts = Index_tree.all_artifacts ii in
      link_odoc_rules
        sctx
        ~all
        [ mld ]
        ~package
        ~libs
        ~indices:(* all_descendent_artifacts @  *) all_artifacts
        ~quiet
    in
    (* Memo.parallel_iter ~f:(fun (x, tree) -> inner (x :: index) tree) children *)
    Memo.return ()
  in
  Memo.parallel_iter ~f:(fun (index, info) -> inner index info) tree
;;

let hierarchical_html_rules sctx (tree : (Index.t * Index_tree.info) list) ~search_db =
  let ctx = Super_context.context sctx in
  List.fold_left
    ~init:(Memo.return [])
    ~f:(fun dirs (index, (ii : Index_tree.info)) ->
      let* dirs = dirs in
      let artifacts =
        let index_artifact = Doc_artifact.index ctx index in
        let all_artifacts = Index_tree.all_artifacts ii in
        List.filter ~f:Doc_artifact.is_visible (index_artifact :: all_artifacts)
      in
      let* new_dirs =
        Memo.List.filter_map artifacts ~f:(fun a -> html_generate ~search_db sctx a)
      in
      let+ () =
        let html_files =
          List.filter artifacts ~f:Doc_artifact.is_visible
          |> List.map ~f:(fun a -> Path.build (Doc_artifact.html_file a))
        in
        let html_alias =
          let html_dir = Index.html_dir ctx index in
          Dep.html_alias html_dir
        in
        Rules.Produce.Alias.add_deps html_alias (Action_builder.paths html_files)
      in
      new_dirs @ dirs)
    tree
;;

(* ; *)
(* Index_tree.fold ~init:(Memo.return []) tree ~f:(fun index (ii : Index_tree.info) dirs -> *)
(*   let* dirs = dirs in *)
(*   let artifacts = *)
(*     let index_artifact = Doc_artifact.index ctx index in *)
(*     let all_artifacts = Index_tree.all_artifacts ii in *)
(*     List.filter ~f:Doc_artifact.is_visible (index_artifact :: all_artifacts) *)
(*   in *)
(*   let* new_dirs = *)
(*     Memo.List.filter_map artifacts ~f:(fun a -> html_generate ~search_db sctx a) *)
(*   in *)
(*   let+ () = *)
(*     let html_files = *)
(*       List.filter artifacts ~f:Doc_artifact.is_visible *)
(*       |> List.map ~f:(fun a -> Path.build (Doc_artifact.html_file a)) *)
(*     in *)
(*     let html_alias = *)
(*       let html_dir = Index.html_dir ctx index in *)
(*       Dep.html_alias html_dir *)
(*     in *)
(*     Rules.Produce.Alias.add_deps html_alias (Action_builder.paths html_files) *)
(*   in *)
(*   new_dirs @ dirs) *)

let compile_module sctx all ~artifact:a ~quiet ~requires ~package ~module_deps ~indices =
  let ctx = Super_context.context sctx in
  let odoc_file = Doc_artifact.odoc_file ctx a in
  let* maps = Valid.libs_maps ctx ~all in
  let+ () =
    let action_with_targets =
      let doc_dir = Path.parent_exn (Path.build (Doc_artifact.odoc_file ctx a)) in
      let run_odoc =
        let cmti = Doc_artifact.source_file a in
        let iflags =
          Command.Args.memo (odoc_include_flags ctx maps package requires indices)
        in
        let parent_id = parent_id ctx a in
        let quiet_arg =
          if quiet then Command.Args.A "--print-warnings=false" else Command.Args.empty
        in
        Odoc.run_odoc
          sctx
          ~dir:doc_dir
          "compile"
          ~flags_for:(Some odoc_file)
          ~quiet
          ([ Command.Args.A "-I"
           ; Path doc_dir
           ; iflags
           ; Hidden_targets [ odoc_file ]
           ; Dep cmti
           ]
           @ parent_id
           @ [ quiet_arg ])
      in
      let file_deps =
        let open Action_builder.O in
        let* valid_libs, _ = Action_builder.of_memo (Valid.get ctx ~all) in
        Dep.deps ctx maps valid_libs package requires
      in
      let open Action_builder.With_targets.O in
      Action_builder.with_no_targets file_deps
      >>> Action_builder.with_no_targets module_deps
      >>> run_odoc
    in
    add_rule sctx action_with_targets
  in
  odoc_file
;;

(* Calculate the dependency libraries for the compilation step. We
   require all of the odoc files for all dependency libraries to be
   created rather than doing any fine-grained dependency management. *)
let compile_requires stdlib_opt libs =
  Memo.List.map ~f:(fun l -> Lib.closure ~linking:false [ l ]) libs
  >>| Resolve.all
  >>| Resolve.map ~f:(fun requires ->
    let requires = List.flatten requires in
    let requires =
      match stdlib_opt with
      | Some l -> l :: requires
      | None -> requires
    in
    List.filter requires ~f:(fun l -> not (List.mem libs l ~equal:lib_equal)))
;;

(* Intra-library module dependencies have to be found out for
   external libraries, but dune already knows these for internal libraries.
   For consistency however, we use the same method for both - we ask odoc. *)
let external_module_deps_rule sctx a =
  match Doc_artifact.artifact_ty a with
  | Module _ ->
    let ctx = Super_context.context sctx in
    let deps_file =
      Path.Build.set_extension (Doc_artifact.odoc_file ctx a) ~ext:".deps"
    in
    let+ () =
      let odoc = Odoc.odoc_program sctx (Paths.root ctx) in
      Super_context.add_rule
        sctx
        ~dir:(Paths.root ctx)
        (Command.run_dyn_prog
           odoc
           ~dir:(Path.parent_exn (Path.build deps_file))
           ~stdout_to:deps_file
           [ A "compile-deps"; Dep (Doc_artifact.source_file a) ])
    in
    Some deps_file
  | _ -> Memo.return None
;;

(* We run [odoc compile-deps] on the cmti files to find out the dependencies.
   This function parses the output. *)
let parse_odoc_deps =
  let rec getdeps cur = function
    | [] -> cur
    | x :: rest ->
      (match String.split ~on:' ' x with
       | [ m; hash ] -> getdeps ((Module_name.of_string m, hash) :: cur) rest
       | _ -> getdeps cur rest)
  in
  fun lines -> getdeps [] lines
;;

(* Here we compile all artifacts - modules and mlds. *)
let compile_odocs sctx ~all ~quiet artifacts libs =
  let ctx = Super_context.context sctx in
  let* requires =
    let* stdlib_opt = stdlib_lib (Context.name ctx) in
    let requires = compile_requires stdlib_opt libs in
    Resolve.Memo.bind requires ~f:(fun libs ->
      let+ libs = Valid.filter_libs ctx ~all libs in
      Resolve.return libs)
  in
  Memo.parallel_iter artifacts ~f:(fun a ->
    external_module_deps_rule sctx a
    >>= function
    | None ->
      (* mld file *)
      let+ (_ : Path.Build.t) = compile_mld sctx a ~quiet:false in
      ()
    | Some deps_file ->
      let module_deps =
        let open Action_builder.O in
        let* l = Action_builder.lines_of (Path.build deps_file) in
        let deps' =
          parse_odoc_deps l
          |> List.filter_map ~f:(fun (m', _) ->
            if Doc_artifact.module_name a = Some m'
            then None
            else
              List.find artifacts ~f:(fun a -> Doc_artifact.module_name a = Some m')
              |> Option.map ~f:(fun a' -> Doc_artifact.odoc_file ctx a' |> Path.build))
        in
        Dune_engine.Dep.Set.of_files deps' |> Action_builder.deps
      in
      let+ (_odoc_file : Path.Build.t) =
        compile_module
          sctx
          all
          ~artifact:a
          ~requires
          ~module_deps
          ~quiet
          ~package:None
          ~indices:[]
      in
      ())
;;

let hierarchical_odoc_rules sctx ~all (tree : (Index.t * Index_tree.info) list) =
  let ctx = Super_context.context sctx in
  let tasks =
    List.map tree ~f:(fun (index, (ii : Index_tree.info)) ->
      let quiet = Index.is_external index in
      let libs = Lib.Map.keys ii.libs in
      let all_artifacts = Index_tree.all_artifacts ii in
      let* () =
        Memo.List.iter
          ~f:(fun a ->
            compile_odocs
              sctx
              ~all
              ~quiet
              a.Index_tree.artifacts
              a.Index_tree.compile_libs)
          ii.artifact_sets
      and* () =
        let package = ii.package in
        link_odoc_rules sctx ~all all_artifacts ~package ~libs ~indices:[] ~quiet
      in
      let all_deps =
        Path.Set.of_list_map all_artifacts ~f:(fun a ->
          Doc_artifact.odoc_file ctx a |> Path.build)
      in
      Dep.setup_deps ctx index all_deps)
  in
  let+ (_ : unit list) = tasks |> Memo.all_concurrently in
  ()
;;

let setup_odoc_rules sctx ~all =
  let* () = Doc_mk_artifacts.full_tree sctx ~all >>= hierarchical_odoc_rules sctx ~all in
  let+ () = Doc_mk_artifacts.full_tree sctx ~all >>= hierarchical_index_rules sctx ~all in
  []
;;

let setup_css_rule sctx =
  let run_odoc =
    let ctx = Super_context.context sctx in
    let dir = Paths.odoc_support ctx in
    let cmd =
      Odoc.run_odoc
        sctx
        ~quiet:false
        ~dir:(Path.build (Context.build_dir ctx))
        "support-files"
        ~flags_for:None
        [ Command.Args.A "-o"; Path (Path.build dir) ]
    in
    Action_builder.With_targets.add_directories cmd ~directory_targets:[ dir ]
  in
  add_rule sctx run_odoc
;;

let static_html_rule ctx =
  let open Paths in
  [ odoc_support ctx ]
;;

let setup_all_html_rules sctx ~all =
  let ctx = Super_context.context sctx in
  let* tree = Doc_mk_artifacts.full_tree sctx ~all in
  let* search_db =
    let dir = Index.html_dir ctx [] in
    let external_odocls, odocls =
      List.fold_left tree ~init:([], []) ~f:(fun acc (index, ii) ->
        let externals, odocls = acc in
        let is_external = Index.is_external index in
        let index_artifact = Doc_artifact.index ctx index in
        let new_artifacts =
          index_artifact :: Index_tree.all_artifacts ii
          |> List.filter_map ~f:(fun a ->
            if Doc_artifact.is_visible a
            then Some (Doc_artifact.odocl_file ctx a)
            else None)
        in
        if is_external
        then new_artifacts @ externals, odocls
        else externals, new_artifacts @ odocls)
    in
    Sherlodoc.search_db sctx ~dir ~external_odocls odocls
  in
  let+ () =
    let html =
      let artifact = Doc_artifact.index ctx [] in
      Doc_artifact.html_file artifact :: static_html_rule ctx
      |> List.map ~f:(fun b -> Path.build b)
    in
    Rules.Produce.Alias.add_deps
      (Dep.html_alias (Index.html_dir ctx []))
      (Action_builder.paths html)
  and+ () =
    let deps =
      List.fold_left ~init:[] tree ~f:(fun acc (index, _) ->
        if index = [] then acc else index :: acc)
      |> Dune_engine.Dep.Set.of_list_map ~f:(fun x ->
        Index.html_dir ctx x |> Dep.html_alias |> Dune_engine.Dep.alias)
    in
    Rules.Produce.Alias.add_deps
      (Dep.html_alias (Index.html_dir ctx []))
      (Action_builder.deps deps)
  and+ dirs = hierarchical_html_rules sctx tree ~search_db
  and+ () = setup_css_rule sctx
  and+ () =
    let dir = Index.html_dir ctx [] in
    Sherlodoc.sherlodoc_dot_js sctx ~dir
  in
  Paths.odoc_support ctx :: dirs
;;

(* End of external rules *)

let gen_project_rules sctx project =
  let ctx = Super_context.context sctx in
  Dune_project.packages project
  |> Dune_lang.Package_name.Map.to_seq
  |> Memo.parallel_iter_seq ~f:(fun (_, (pkg : Package.t)) ->
    let dir =
      let pkg_dir = Package.dir pkg in
      Path.Build.append_source (Context.build_dir ctx) pkg_dir
    in
    let register =
      let alias = Alias.make Alias0.doc_very_new ~dir in
      fun () ->
        let top_alias = Dep.html_alias (Index.html_dir ctx []) in
        Dune_engine.Dep.alias top_alias
        |> Dune_engine.Dep.Set.singleton
        |> Action_builder.deps
        |> Rules.Produce.Alias.add_deps alias
    in
    let+ () = register () in
    ())
;;

let has_rules m =
  let* dirs, rules = Rules.collect (fun () -> m) in
  let directory_targets =
    Path.Build.Map.of_list_map_exn dirs ~f:(fun dir -> dir, Loc.none)
  in
  Memo.return (Gen_rules.make ~directory_targets (Memo.return rules))
;;

let gen_rules sctx ~dir rest =
  let all = true in
  match rest with
  | [] ->
    Memo.return
      (Build_config.Gen_rules.make
         ~build_dir_only_sub_dirs:
           (Build_config.Gen_rules.Build_only_sub_dirs.singleton ~dir Subdir_set.all)
         (Memo.return Rules.empty))
  | [ "odoc" ] -> has_rules (setup_odoc_rules sctx ~all)
  | [ "html" ] -> has_rules (setup_all_html_rules sctx ~all)
  | _ -> Memo.return (Gen_rules.redirect_to_parent Gen_rules.Rules.empty)
;;
