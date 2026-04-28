open Import
open Memo.O

let ( ++ ) = Path.Build.relative

let create_artifact_module ~local_lib ~module_ =
  let mod_ =
    { Odoc_target.visible = Module.visibility module_ = Visibility.Public
    ; module_name = Module_name.Unique.to_name (Module.obj_name module_) ~loc:Loc.none
    }
  in
  let kind = Odoc_artifact.Module (mod_, Odoc_target.Lib local_lib) in
  let obj_dir = Lib.Local.obj_dir local_lib in
  let source_file = Obj_dir.Module.cmti_file obj_dir module_ ~cm_kind:(Ocaml Cmi) in
  Odoc_artifact.create ~kind ~source:(Local_source source_file)
;;

let discover_local_lib_artifacts sctx ~local_lib =
  let+ all_modules =
    Dir_contents.modules_of_local_lib sctx local_lib ~for_:Compilation_mode.Ocaml
  in
  let modules = Modules.fold all_modules ~init:[] ~f:(fun m acc -> m :: acc) in
  List.map modules ~f:(fun module_ -> create_artifact_module ~local_lib ~module_)
;;

let discover_pkg_mld_artifacts ~pkg ~pkg_libs ~mld_infos =
  let target = Odoc_target.Pkg pkg in
  List.map mld_infos ~f:(fun (source, name) ->
    let page = { Odoc_target.name; pkg_libs } in
    let kind = Odoc_artifact.Page (page, target) in
    Odoc_artifact.create ~kind ~source)
;;

let auto_index_path ctx pkg = Odoc_paths.gen_mld_dir ctx pkg ++ "index.mld"

let discover_all_lib_artifacts sctx ~libs =
  Memo.List.filter_map libs ~f:(fun lib ->
    match Lib.Local.of_lib lib with
    | None -> Memo.return None
    | Some local_lib ->
      let+ artifacts = discover_local_lib_artifacts sctx ~local_lib in
      Some (lib, artifacts))
;;

let check_mlds_no_dupes ~pkg ~mlds =
  match
    List.map mlds ~f:(fun (mld : Doc_sources.mld) ->
      let in_doc_str = Path.Local.to_string mld.in_doc in
      let name = Filename.remove_extension in_doc_str |> Filename.to_string in
      name, mld.path)
    |> String.Map.of_list
  with
  | Ok _ -> ()
  | Error (_, p1, p2) ->
    User_error.raise
      [ Pp.textf
          "Package %s has two mld's with the same basename %s, %s"
          (Package.Name.to_string pkg)
          (Path.to_string_maybe_quoted (Path.build p1))
          (Path.to_string_maybe_quoted (Path.build p2))
      ]
;;

let get_local_mld_infos sctx ~pkg =
  let+ source_mlds = Packages.mlds sctx pkg in
  check_mlds_no_dupes ~pkg ~mlds:source_mlds;
  List.map source_mlds ~f:(fun (mld : Doc_sources.mld) ->
    let in_doc_str = Path.Local.to_string mld.in_doc in
    let name = Filename.remove_extension in_doc_str |> Filename.to_string in
    let source = Odoc_artifact.Local_source mld.path in
    source, name)
;;

let discover_pkg_artifacts_common sctx ctx ~pkg ~libs ~mld_infos ~default_index =
  let lib_subdirs = List.map libs ~f:(fun lib -> Lib.name lib |> Lib_name.to_string) in
  let* lib_artifacts = discover_all_lib_artifacts sctx ~libs in
  let has_pkg_index =
    List.exists mld_infos ~f:(fun (_, name) -> String.equal name "index")
  in
  let mld_infos, gen_index =
    if has_pkg_index
    then mld_infos, None
    else (
      let path = auto_index_path ctx pkg in
      let content = default_index ~pkg ~lib_artifacts in
      mld_infos @ [ Odoc_artifact.Local_source path, "index" ], Some (path, content))
  in
  let mld_artifacts = discover_pkg_mld_artifacts ~pkg ~pkg_libs:libs ~mld_infos in
  let all_module_artifacts = List.concat_map lib_artifacts ~f:snd in
  let all_artifacts = mld_artifacts @ all_module_artifacts in
  Memo.return (all_artifacts, lib_subdirs, gen_index)
;;

(* Discover artifacts for a private library.
   Takes the fields from Scope_id.Private_lib directly to make invalid calls impossible. *)
let discover_private_lib_artifacts sctx ctx ~lib_name ~project =
  let* lib_db =
    let+ scope = Scope.DB.find_by_project (Context.name ctx) project in
    Scope.libs scope
  in
  let* lib_opt =
    let+ lib = Lib.DB.find lib_db lib_name in
    Option.bind ~f:Lib.Local.of_lib lib
  in
  match lib_opt with
  | None -> Memo.return ([], [])
  | Some local_lib ->
    let+ module_artifacts = discover_local_lib_artifacts sctx ~local_lib in
    module_artifacts, []
;;

let discover_local_pkg_artifacts sctx ctx ~pkg ~default_index =
  let* { Scope.DB.Lib_entry.Set.libraries; _ } =
    Scope.DB.lib_entries_of_package (Context.name ctx) pkg
  in
  let libs =
    List.filter_map libraries ~f:(fun lib ->
      let lib_t = Lib.Local.to_lib lib in
      match Lib.info lib_t |> Lib_info.implements with
      | None -> Some lib_t
      | Some _ -> None)
  in
  let* mld_infos = get_local_mld_infos sctx ~pkg in
  discover_pkg_artifacts_common sctx ctx ~pkg ~libs ~mld_infos ~default_index
;;

let discover_package_artifacts sctx ctx ~default_index ~pkg_or_lib_unique_name =
  let* scope_id = Odoc_scope.Scope_id.of_string pkg_or_lib_unique_name in
  match scope_id with
  | Odoc_scope.Scope_id.Private_lib { unique_name = _; lib_name; project } ->
    let+ artifacts, lib_subdirs =
      discover_private_lib_artifacts sctx ctx ~lib_name ~project
    in
    artifacts, lib_subdirs, None
  | Odoc_scope.Scope_id.Package pkg ->
    discover_local_pkg_artifacts sctx ctx ~pkg ~default_index
;;

let collect_all_visible_odocls sctx ~default_index ~workspace_pkgs =
  let ctx = Super_context.context sctx in
  Memo.List.concat_map workspace_pkgs ~f:(fun pkg ->
    let pkg_name = Package.Name.to_string pkg in
    let+ all_artifacts, _lib_subdirs, _gen_index =
      discover_package_artifacts sctx ctx ~default_index ~pkg_or_lib_unique_name:pkg_name
    in
    List.filter_map all_artifacts ~f:(fun artifact ->
      if Odoc_artifact.hidden artifact
      then None
      else Some (Odoc_artifact.odocl_file ctx artifact)))
;;
