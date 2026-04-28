open Import
open Memo.O

let ( ++ ) = Path.Build.relative
let mld_ext = Filename.Extension.of_string_exn ".mld"

let module_artifact ~local_lib module_ =
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
  List.map modules ~f:(module_artifact ~local_lib)
;;

let discover_pkg_mld_artifacts ~pkg ~mld_infos =
  let target = Odoc_target.Pkg pkg in
  List.map mld_infos ~f:(fun (source, name) ->
    let kind = Odoc_artifact.Page ({ Odoc_target.name }, target) in
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
    List.map mlds ~f:(fun ((_path, name) as mld) -> name, mld) |> String.Map.of_list
  with
  | Ok _ -> ()
  | Error (_, (p1, _), (p2, _)) ->
    User_error.raise
      [ Pp.textf
          "Package %s has two mld's with the same basename %s, %s"
          (Package.Name.to_string pkg)
          (Path.to_string_maybe_quoted (Path.build p1))
          (Path.to_string_maybe_quoted (Path.build p2))
      ]
;;

let mlds sctx pkg =
  let+ mlds = Packages.mlds sctx pkg in
  List.partition_map mlds ~f:(fun (mld : Doc_sources.mld) ->
    match Path.Local.explode mld.in_doc with
    | [ name ] ->
      let ext = Filename.extension name in
      if Filename.Extension.Or_empty.check ext mld_ext
      then Left (mld.path, Filename.remove_extension name |> Filename.to_string)
      else Right mld
    | _ -> Right mld)
;;

let report_warnings warnings =
  match warnings with
  | [] -> ()
  | _ :: _ ->
    let l =
      warnings
      |> List.map ~f:(fun (mld : Doc_sources.mld) -> Path.Local.to_string mld.in_doc)
      |> List.sort ~compare:String.compare
      |> String.concat ~sep:", "
    in
    User_warning.emit
      [ Pp.textf
          "Dune does not yet support building documentation for assets, and mlds in a \
           non-flat hierarchy. Ignoring %s."
          l
      ]
;;

let get_local_mld_infos =
  let memo =
    Memo.create
      "odoc-package-mlds"
      ~input:(module Super_context.As_memo_key.And_package_name)
      (fun (sctx, pkg) ->
         let+ flat, dropped = mlds sctx pkg in
         report_warnings dropped;
         check_mlds_no_dupes ~pkg ~mlds:flat;
         List.map flat ~f:(fun (path, name) -> Odoc_artifact.Local_source path, name))
  in
  fun sctx ~pkg -> Memo.exec memo (sctx, pkg)
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
  let mld_artifacts = discover_pkg_mld_artifacts ~pkg ~mld_infos in
  let all_module_artifacts = List.concat_map lib_artifacts ~f:snd in
  let all_artifacts = mld_artifacts @ all_module_artifacts in
  Memo.return (all_artifacts, lib_subdirs, gen_index)
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
  let* lib_name, lib_db =
    Odoc_scope.Scope_key.of_string (Context.name ctx) pkg_or_lib_unique_name
  in
  let* lib_opt =
    let+ lib = Lib.DB.find lib_db lib_name in
    Option.bind ~f:Lib.Local.of_lib lib
  in
  match lib_opt with
  | Some local_lib when Option.is_none (Lib_info.package (Lib.Local.info local_lib)) ->
    let+ module_artifacts = discover_local_lib_artifacts sctx ~local_lib in
    module_artifacts, [], None, None
  | _ ->
    let pkg = Package.Name.of_string pkg_or_lib_unique_name in
    let+ artifacts, lib_subdirs, gen_index =
      discover_local_pkg_artifacts sctx ctx ~pkg ~default_index
    in
    artifacts, lib_subdirs, gen_index, Some pkg
;;
