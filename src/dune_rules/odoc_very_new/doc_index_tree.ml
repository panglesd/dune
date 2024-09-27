open Memo.O
open Import
open Doc_pkgs
open Doc_index

module Index_tree = struct
  type artifact_info =
    { artifacts : Doc_artifact.t list
    ; compile_libs : Lib.t list
    }

  type info =
    { artifact_sets : artifact_info list
    ; predefined_index : Path.t option
    ; libs : Doc_artifact.t list Lib.Map.t
    ; package : Package.Name.t option
    ; is_fallback : bool
    }

  let all_artifacts info =
    List.fold_left ~init:[] info.artifact_sets ~f:(fun acc x ->
      List.rev_append x.artifacts acc)
  ;;
end

let ext_package_mlds (ctx : Context.t) (pkg : Package.Name.t) =
  let* findlib = Findlib.create (Context.name ctx) in
  Findlib.find_root_package findlib pkg
  >>| function
  | Error _ -> []
  | Ok dpkg ->
    let installed = dpkg.files in
    List.filter_map installed ~f:(function
      | Dune_section.Doc, fs ->
        let doc_path = Section.Map.find_exn dpkg.sections Doc in
        Some
          (List.filter_map fs ~f:(function
            | `File, dst ->
              let str = Install.Entry.Dst.to_string dst in
              if Filename.check_suffix str ".mld"
              then Some (Path.relative doc_path str)
              else None
            | _ -> None))
      | _ -> None)
    |> List.concat
;;

let pkg_mlds sctx pkg =
  let* pkgs = Dune_load.packages () in
  if Package.Name.Map.mem pkgs pkg
  then Packages.mlds sctx pkg >>| List.map ~f:Path.build
  else (
    let ctx = Super_context.context sctx in
    ext_package_mlds ctx pkg)
;;

let check_mlds_no_dupes ~pkg ~mlds =
  match
    List.rev_map mlds ~f:(fun mld -> Filename.remove_extension (Path.basename mld), mld)
    |> Filename.Map.of_list
  with
  | Ok m -> m
  | Error (_, p1, p2) ->
    User_error.raise
      [ Pp.textf
          "Package %s has two mld's with the same basename %s, %s"
          (Package.Name.to_string pkg)
          (Path.to_string_maybe_quoted p1)
          (Path.to_string_maybe_quoted p2)
      ]
;;

let pkg_artifacts sctx index pkg =
  let ctx = Super_context.context sctx in
  let+ mlds_map =
    let+ mlds = pkg_mlds sctx pkg in
    check_mlds_no_dupes ~pkg ~mlds
  in
  let artifacts =
    let mlds_noindex = String.Map.filteri ~f:(fun i _ -> i <> "index") mlds_map in
    String.Map.values mlds_noindex
    |> List.map ~f:(fun mld -> Doc_artifact.external_mld ctx index mld)
  in
  let index_file = String.Map.find mlds_map "index" in
  index_file, artifacts
;;

let index_info_of_pkg_def =
  let f (sctx, all, pkg_name) =
    let* maps =
      let ctx = Super_context.context sctx in
      Valid.libs_maps ctx ~all
    in
    let index = Index.of_pkg maps pkg_name in
    let+ main_index_path, main_artifacts = pkg_artifacts sctx index pkg_name in
    let pkg_index_info =
      ( index
      , { Index_tree.libs = Lib.Map.empty
        ; artifact_sets = [ { artifacts = main_artifacts; compile_libs = [] } ]
        ; predefined_index = main_index_path
        ; package = Some pkg_name
        ; is_fallback = false
        } )
    in
    [ pkg_index_info ]
  in
  let module Input = struct
    module Super_context = Super_context.As_memo_key

    type t = Super_context.t * bool * Package.Name.t

    let equal (c1, b1, n1) (c2, b2, n2) =
      Super_context.equal c1 c2 && Package.Name.equal n1 n2 && b1 = b2
    ;;

    let hash (c, b, n) = Poly.hash (Super_context.hash c, b, Package.Name.hash n)

    let to_dyn (c, b, n) =
      Dyn.Tuple [ Super_context.to_dyn c; Dyn.bool b; Package.Name.to_dyn n ]
    ;;
  end
  in
  Memo.create "index_info_of_pkg" ~input:(module Input) f
;;

let index_info_of_pkg sctx all pkg_name =
  Memo.exec index_info_of_pkg_def (sctx, all, pkg_name)
;;
