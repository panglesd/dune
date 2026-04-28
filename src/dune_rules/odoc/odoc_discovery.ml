open Import
open Memo.O

let ( ++ ) = Path.Build.relative
let sprintf = Printf.sprintf

let get_workspace_packages () =
  let* packages = Dune_load.packages () in
  let* mask = Dune_load.mask () in
  let all_pkgs = Package.Name.Map.keys packages in
  match Only_packages.enumerate mask with
  | `All -> Memo.return all_pkgs
  | `Set visible_pkgs ->
    Memo.return (List.filter all_pkgs ~f:(Package.Name.Set.mem visible_pkgs))
;;

let libs_of_pkg (ctx : Context.t) ~pkg =
  let* packages = Dune_load.packages () in
  if Package.Name.Map.mem packages pkg
  then
    let+ { Scope.DB.Lib_entry.Set.libraries; _ } =
      Scope.DB.lib_entries_of_package (Context.name ctx) pkg
    in
    List.filter_map libraries ~f:(fun lib ->
      let lib_t = Lib.Local.to_lib lib in
      match Lib.info lib_t |> Lib_info.implements with
      | None -> Some lib_t
      | Some _ -> None)
  else
    let* pkg_discovery = Package_discovery.create ~context:ctx in
    Memo.return (Package_discovery.libraries_of_package pkg_discovery pkg)
;;

let vlib_impl_libs_of_local_pkg (ctx : Context.t) ~pkg =
  let* packages = Dune_load.packages () in
  if Package.Name.Map.mem packages pkg
  then
    let+ { Scope.DB.Lib_entry.Set.libraries; _ } =
      Scope.DB.lib_entries_of_package (Context.name ctx) pkg
    in
    List.filter libraries ~f:(fun impl_local_lib ->
      Lib.Local.to_lib impl_local_lib |> Lib.implements |> Option.is_some)
  else Memo.return []
;;

let default_pkg_index ~pkg ~lib_artifacts =
  let b = Buffer.create 512 in
  Printf.bprintf b "{0 %s index}\n" (Package.Name.to_string pkg);
  List.sort lib_artifacts ~compare:(fun (x, _) (y, _) ->
    Lib_name.compare (Lib.name x) (Lib.name y))
  |> List.iter ~f:(fun (lib, artifacts) ->
    let modules =
      List.filter_map artifacts ~f:(fun artifact ->
        if Odoc_artifact.hidden artifact
        then None
        else (
          match Odoc_artifact.get_kind artifact with
          | Module ({ visible = true; module_name; _ }, _) -> Some module_name
          | _ -> None))
    in
    Printf.bprintf b "{1 Library %s}\n" (Lib_name.to_string (Lib.name lib));
    Buffer.add_string
      b
      (match modules with
       | [ x ] ->
         sprintf
           "The entry point of this library is the module:\n{!module-%s}.\n"
           (Module_name.to_string x)
       | _ ->
         sprintf
           "This library exposes the following toplevel modules:\n{!modules:%s}\n"
           (modules
            |> List.sort ~compare:Module_name.compare
            |> List.map ~f:Module_name.to_string
            |> String.concat ~sep:" ")));
  Buffer.contents b
;;

let create_artifact_module ~target ~local_lib ~module_ ~cmti_obj_dir =
  let mod_ =
    { Odoc_target.visible = Module.visibility module_ = Visibility.Public
    ; module_name = Module_name.Unique.to_name (Module.obj_name module_) ~loc:Loc.none
    }
  in
  let kind = Odoc_artifact.Module (mod_, target) in
  let obj_dir =
    match cmti_obj_dir with
    | Some d -> d
    | None -> Lib.Local.obj_dir local_lib
  in
  let source_file = Obj_dir.Module.cmti_file obj_dir module_ ~cm_kind:(Ocaml Cmi) in
  Odoc_artifact.create ~kind ~source:(Local_source source_file)
;;

let discover_local_lib_artifacts sctx _ctx ~lib_name ~local_lib
  : Odoc_artifact.t list Memo.t
  =
  let* all_modules =
    Dir_contents.modules_of_local_lib sctx local_lib ~for_:Compilation_mode.Ocaml
  in
  let modules = Modules.fold all_modules ~init:[] ~f:(fun m acc -> m :: acc) in
  let info = Lib.Local.info local_lib in
  let pkg = Lib_info.package info in
  let lib_t = Lib.Local.to_lib local_lib in
  let* vlib_obj_dir =
    match Lib.implements lib_t with
    | None -> Memo.return None
    | Some vlib_resolve ->
      let+ vlib = Resolve.Memo.read_memo vlib_resolve in
      (match Lib.Local.of_lib vlib with
       | Some local_vlib -> Some (Lib.Local.obj_dir local_vlib)
       | None -> None)
  in
  let target =
    match pkg with
    | None ->
      (* Private library - use lib_unique_name for directory structure *)
      let status = Lib_info.status info in
      let lib_unique_name =
        match status with
        | Lib_info.Status.Private (project, _) ->
          Odoc_scope.Scope_key.to_string lib_name project
        | _ ->
          Lib_name.to_string lib_name (* Fallback, shouldn't happen for private libs *)
      in
      Odoc_target.Private_lib (lib_unique_name, lib_t)
    | Some pkg ->
      (* Library with package - use pkg/lib directory structure *)
      Odoc_target.Lib (pkg, lib_t)
  in
  let artifacts =
    List.map modules ~f:(fun module_ ->
      let cmti_obj_dir =
        match vlib_obj_dir with
        | Some _ when Module.file module_ ~ml_kind:Intf <> None -> vlib_obj_dir
        | _ -> None
      in
      create_artifact_module ~target ~local_lib ~module_ ~cmti_obj_dir)
  in
  Memo.return artifacts
;;

let discover_pkg_mld_artifacts ~pkg ~pkg_libs ~mld_infos =
  let target = Odoc_target.Pkg pkg in
  let mld_artifacts =
    List.map mld_infos ~f:(fun (source, name) ->
      let page = { Odoc_target.name; pkg_libs } in
      let kind = Odoc_artifact.Page (page, target) in
      Odoc_artifact.create ~kind ~source)
  in
  let has_index = List.exists mld_infos ~f:(fun (_, name) -> String.equal name "index") in
  mld_artifacts, has_index
;;

let create_pkg_index_artifact ctx ~pkg ~pkg_libs ~lib_artifacts =
  let target = Odoc_target.Pkg pkg in
  let output_path = Odoc_paths.gen_mld_dir ctx pkg ++ "index.mld" in
  let page = { Odoc_target.name = "index"; pkg_libs } in
  let kind = Odoc_artifact.Page (page, target) in
  let content = default_pkg_index ~pkg ~lib_artifacts in
  let source = Odoc_artifact.Generated { content; output_path } in
  Odoc_artifact.create ~kind ~source
;;

(* Extract page name from installed mld path by finding odoc-pages ancestor.
   E.g., /lib/pkg/odoc-pages/foo/bar.mld -> "foo/bar" *)
let page_name_from_installed_mld_path mld_path =
  let rec find_odoc_pages_ancestor p =
    match Path.parent p with
    | None -> None
    | Some parent ->
      if Path.basename parent = "odoc-pages"
      then Some parent
      else find_odoc_pages_ancestor parent
  in
  match find_odoc_pages_ancestor mld_path with
  | Some odoc_pages_dir ->
    (match Path.drop_prefix mld_path ~prefix:odoc_pages_dir with
     | Some rel_path ->
       let rel_str = Path.Local.to_string rel_path in
       Filename.remove_extension rel_str
     | None -> Path.basename mld_path |> Filename.remove_extension)
  | None -> Path.basename mld_path |> Filename.remove_extension
;;

(* Get archive names for a library (used to filter odoc classify output) *)
let get_archive_names lib_name archives =
  let byte_archives = Mode.Dict.get archives Mode.Byte in
  match byte_archives with
  | [] ->
    if Lib_name.equal lib_name (Lib_name.of_string "stdlib") then [ "stdlib" ] else []
  | archives ->
    List.map archives ~f:(fun p -> Path.basename p |> Filename.remove_extension)
;;

(* Parse odoc classify output to extract module names for specific archives *)
let parse_classify_output ~archive_names classify_content =
  let classify_lines = String.split_lines classify_content in
  List.concat_map classify_lines ~f:(fun line ->
    match
      String.split line ~on:' ' |> List.filter ~f:(fun s -> not (String.is_empty s))
    with
    | [] -> []
    | archive :: mods ->
      if List.mem archive_names archive ~equal:String.equal then mods else [])
;;

let discover_installed_lib_artifacts _sctx ctx ~pkg ~lib_name ~lib
  : Odoc_artifact.t list Memo.t
  =
  Log.info
    (sprintf
       "discover_installed_lib_artifacts: pkg=%s lib=%s"
       (Package.Name.to_string pkg)
       (Lib_name.to_string lib_name))
    [];
  let pkg_name_str = Package.Name.to_string pkg in
  let lib_name_str = Lib_name.to_string lib_name in
  let info = Lib.info lib in
  let archive_names = get_archive_names lib_name (Lib_info.archives info) in
  if List.is_empty archive_names
  then (
    Log.info
      (sprintf
         "odoc v3: No archives found for installed library %s/%s, skipping"
         pkg_name_str
         lib_name_str)
      [];
    Memo.return [])
  else (
    (* Read and parse classify file to get module names *)
    let classify_path =
      Odoc_paths.root ctx ++ "classify" ++ pkg_name_str ++ lib_name_str ++ "odoc.classify"
    in
    let* classify_content = Build_system.read_file (Path.build classify_path) in
    let all_module_names = parse_classify_output ~archive_names classify_content in
    Log.info
      (sprintf
         "odoc v3: Found %d modules for installed library %s/%s via odoc classify"
         (List.length all_module_names)
         pkg_name_str
         lib_name_str)
      [];
    if List.is_empty all_module_names
    then Memo.return []
    else
      let* pkg_discovery = Package_discovery.create ~context:ctx in
      let target = Odoc_target.Lib (pkg, lib) in
      let+ all_module_artifacts =
        Memo.parallel_map all_module_names ~f:(fun module_name ->
          match Package_discovery.module_source_file pkg_discovery ~lib ~module_name with
          | Some src_path ->
            let mod_ =
              { Odoc_target.visible = not (String.contains_double_underscore module_name)
              ; module_name = Module_name.of_checked_string module_name
              }
            in
            let module_artifact =
              Odoc_artifact.create
                ~kind:(Module (mod_, target))
                ~source:(Installed_source { src_path })
            in
            Memo.return (Some module_artifact)
          | None ->
            Log.info
              (sprintf
                 "odoc v3: Could not find source file for module %s in %s/%s"
                 module_name
                 pkg_name_str
                 lib_name_str)
              [];
            Memo.return None)
      in
      List.filter_map all_module_artifacts ~f:Fun.id)
;;

let discover_lib_artifacts sctx ctx ~pkg ~lib_name ~lib : Odoc_artifact.t list Memo.t =
  match Lib.Local.of_lib lib with
  | Some local_lib -> discover_local_lib_artifacts sctx ctx ~lib_name ~local_lib
  | None -> discover_installed_lib_artifacts sctx ctx ~pkg ~lib_name ~lib
;;

let discover_all_lib_artifacts sctx ctx ~pkg ~libs =
  Memo.List.map libs ~f:(fun lib ->
    let lib_name = Lib.name lib in
    let+ artifacts = discover_lib_artifacts sctx ctx ~pkg ~lib_name ~lib in
    lib, artifacts)
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

let discover_pkg_artifacts_common sctx ctx ~pkg ~libs ~mld_infos =
  let lib_subdirs = List.map libs ~f:(fun lib -> Lib.name lib |> Lib_name.to_string) in
  let mld_artifacts, has_pkg_index =
    discover_pkg_mld_artifacts ~pkg ~pkg_libs:libs ~mld_infos
  in
  let* lib_artifacts = discover_all_lib_artifacts sctx ctx ~pkg ~libs in
  let pkg_index_artifact =
    if has_pkg_index
    then []
    else [ create_pkg_index_artifact ctx ~pkg ~pkg_libs:libs ~lib_artifacts ]
  in
  let all_module_artifacts = List.concat_map lib_artifacts ~f:snd in
  let all_artifacts = mld_artifacts @ pkg_index_artifact @ all_module_artifacts in
  Memo.return (all_artifacts, lib_subdirs)
;;

(* Discover artifacts for a private library.
   Takes the fields from Scope_id.Private_lib directly to make invalid calls impossible. *)
let discover_private_lib_artifacts sctx ctx ~lib_name ~project
  : (Odoc_artifact.t list * string list) Memo.t
  =
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
    let+ module_artifacts = discover_local_lib_artifacts sctx ctx ~lib_name ~local_lib in
    module_artifacts, []
;;

let discover_local_pkg_artifacts sctx ctx ~pkg
  : (Odoc_artifact.t list * string list) Memo.t
  =
  let* all_libs = libs_of_pkg ctx ~pkg in
  let libs =
    List.filter_map all_libs ~f:(fun lib ->
      Option.map (Lib.Local.of_lib lib) ~f:Lib.Local.to_lib)
  in
  let* mld_infos = get_local_mld_infos sctx ~pkg in
  let* base_artifacts, lib_subdirs =
    discover_pkg_artifacts_common sctx ctx ~pkg ~libs ~mld_infos
  in
  let* impl_artifacts =
    let* impl_libs = vlib_impl_libs_of_local_pkg ctx ~pkg in
    Memo.List.concat_map impl_libs ~f:(fun impl_local_lib ->
      let lib_name = Lib.name (Lib.Local.to_lib impl_local_lib) in
      discover_local_lib_artifacts sctx ctx ~lib_name ~local_lib:impl_local_lib)
  in
  Memo.return (base_artifacts @ impl_artifacts, lib_subdirs)
;;

let discover_installed_pkg_artifacts sctx ctx ~pkg
  : (Odoc_artifact.t list * string list) Memo.t
  =
  Log.info
    (sprintf "discover_installed_pkg_artifacts: pkg=%s" (Package.Name.to_string pkg))
    [];
  let* pkg_discovery = Package_discovery.create ~context:ctx in
  let all_libs = Package_discovery.libraries_of_package pkg_discovery pkg in
  let libs =
    List.filter all_libs ~f:(fun lib ->
      Option.is_none (Lib_info.implements (Lib.info lib)))
  in
  Log.info
    (sprintf
       "discover_installed_pkg_artifacts(%s): got %d libs"
       (Package.Name.to_string pkg)
       (List.length libs))
    [];
  let mld_files = Package_discovery.mlds_of_package pkg_discovery pkg in
  let mld_infos =
    List.map mld_files ~f:(fun (mld_path, _dst) ->
      let name = page_name_from_installed_mld_path mld_path in
      let source = Odoc_artifact.Installed_source { src_path = mld_path } in
      source, name)
  in
  discover_pkg_artifacts_common sctx ctx ~pkg ~libs ~mld_infos
;;

let discover_package_artifacts sctx ctx ~pkg_or_lib_unique_name
  : (Odoc_artifact.t list * string list) Memo.t
  =
  let* scope_id = Odoc_scope.Scope_id.of_string pkg_or_lib_unique_name in
  match scope_id with
  | Odoc_scope.Scope_id.Private_lib { unique_name = _; lib_name; project } ->
    discover_private_lib_artifacts sctx ctx ~lib_name ~project
  | Odoc_scope.Scope_id.Package pkg ->
    let* is_project_pkg =
      let* packages = Dune_load.packages () in
      Memo.return (Package.Name.Map.mem packages pkg)
    in
    Log.info
      (sprintf
         "discover_package_artifacts(%s): is_project_pkg=%b"
         pkg_or_lib_unique_name
         is_project_pkg)
      [];
    if is_project_pkg
    then discover_local_pkg_artifacts sctx ctx ~pkg
    else discover_installed_pkg_artifacts sctx ctx ~pkg
;;

let collect_all_visible_odocls sctx () =
  let ctx = Super_context.context sctx in
  let* workspace_pkgs = get_workspace_packages () in
  let* pkg_odocl_files =
    Memo.List.concat_map workspace_pkgs ~f:(fun pkg ->
      let pkg_name = Package.Name.to_string pkg in
      let* all_artifacts, _lib_subdirs =
        discover_package_artifacts sctx ctx ~pkg_or_lib_unique_name:pkg_name
      in
      Memo.return
        (List.filter_map all_artifacts ~f:(fun artifact ->
           if Odoc_artifact.hidden artifact
           then None
           else Some (Odoc_artifact.odocl_file ctx artifact))))
  in
  Memo.return (workspace_pkgs, pkg_odocl_files)
;;
