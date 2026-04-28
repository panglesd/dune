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

let find_local_package pkg =
  let+ packages = Dune_load.packages () in
  Package.Name.Map.find packages pkg
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

(* Get :with-doc package dependencies for a local package, or [] for installed
   packages. Validates that each named package actually exists. *)
let resolve_pkg_doc_deps ctx ~pkg =
  let* local_pkg_opt = find_local_package pkg in
  match local_pkg_opt with
  | None -> Memo.return ([], [])
  | Some local_pkg ->
    let with_doc = Package_variable_name.with_doc in
    let packages =
      Package.depends local_pkg
      |> List.filter ~f:(Package_dependency.has_constraint_on with_doc)
      |> List.map ~f:(fun (dep : Package_dependency.t) -> dep.name)
    in
    let* all_packages = Dune_load.packages () in
    let* pkg_discovery = Package_discovery.create ~context:ctx in
    Memo.List.fold_left packages ~init:([], []) ~f:(fun (libs_acc, pkgs_acc) pkg_name ->
      let exists =
        Package.Name.Map.mem all_packages pkg_name
        || not
             (List.is_empty
                (Package_discovery.libraries_of_package pkg_discovery pkg_name))
      in
      if not exists
      then
        User_error.raise
          [ Pp.textf
              "Documentation dependency %S is not installed."
              (Package.Name.to_string pkg_name)
          ]
      else
        let+ pkg_libs = libs_of_pkg ctx ~pkg:pkg_name in
        libs_acc @ pkg_libs, pkgs_acc @ [ pkg_name ])
;;

module Toplevel_index = struct
  type pkg_item =
    { name : string
    ; version : Package_version.t option
    }

  type item = Package of pkg_item

  let of_packages packages =
    Package.Name.Map.to_list_map packages ~f:(fun name package ->
      let name = Package.Name.to_string name in
      Package { name; version = Package.version package })
  ;;

  let mld_content t =
    let b = Buffer.create 1024 in
    Printf.bprintf b "{0 OCaml package documentation}\n\n";
    List.iter t ~f:(fun (Package { name; version }) ->
      let version_suffix =
        match version with
        | None -> ""
        | Some v -> sprintf " (%s)" (Package_version.to_string v)
      in
      Printf.bprintf b "- {{!/%s/page-index}%s}%s\n" name name version_suffix);
    Buffer.contents b
  ;;

  let get_items _ctx =
    let+ packages = Dune_load.packages () in
    of_packages packages
  ;;
end

let library_index_content_from_artifacts ~lib_name ~artifacts =
  let b = Buffer.create 256 in
  Printf.bprintf b "@toc_status hidden\n";
  Printf.bprintf b "@order_category libraries\n";
  Printf.bprintf b "{0 Library [%s]}\n" (Lib_name.to_string lib_name);
  (* Extract non-hidden, visible modules from artifacts.
     Odoc_artifact.hidden filters out implementation modules (Foo__Bar, Foo__). *)
  let module_names =
    List.filter_map artifacts ~f:(fun artifact ->
      if Odoc_artifact.hidden artifact
      then None
      else (
        match Odoc_artifact.get_kind artifact with
        | Module ({ visible = true; module_name; _ }, _) -> Some module_name
        | Module ({ visible = false; _ }, _) | Page _ -> None))
    |> List.sort ~compare:Module_name.compare
  in
  if not (List.is_empty module_names)
  then (
    Printf.bprintf b "{!modules:";
    List.iter module_names ~f:(fun m -> Printf.bprintf b " %s" (Module_name.to_string m));
    Printf.bprintf b "}\n");
  Buffer.contents b
;;

(* Generate default package index.mld content from artifacts organized by library.
   Lists entry modules for each library. *)
let default_pkg_index ~pkg ~lib_artifacts =
  let b = Buffer.create 512 in
  Printf.bprintf b "{0 %s index}\n" (Package.Name.to_string pkg);
  let sorted_libs =
    List.sort lib_artifacts ~compare:(fun (lib1, _) (lib2, _) ->
      Lib_name.compare (Lib.name lib1) (Lib.name lib2))
  in
  List.iter sorted_libs ~f:(fun (lib, artifacts) ->
    let lib_name = Lib.name lib in
    let modules =
      List.filter_map artifacts ~f:(fun artifact ->
        if Odoc_artifact.hidden artifact
        then None
        else (
          match Odoc_artifact.get_kind artifact with
          | Module ({ visible = true; module_name; _ }, _) -> Some module_name
          | _ -> None))
      |> List.sort ~compare:Module_name.compare
    in
    if not (List.is_empty modules)
    then (
      Printf.bprintf b "{1 Library %s}\n" (Lib_name.to_string lib_name);
      Buffer.add_string
        b
        (match modules with
         | [ x ] ->
           sprintf
             "The entry point of this library is the module:\n{!/%s/module-%s}.\n"
             (Lib_name.to_string lib_name)
             (Module_name.to_string x)
         | _ ->
           (* TODO: Use qualified paths like {!modules:/lib/Foo /lib/Bar} once odoc
              supports this syntax in the {!modules:} directive. Currently only
              bare module names are supported. *)
           sprintf
             "This library exposes the following toplevel modules:\n{!modules:%s}\n"
             (modules |> List.map ~f:Module_name.to_string |> String.concat ~sep:" "))));
  Buffer.contents b
;;

let create_artifact_module
      ~target
      ~local_lib
      ~module_
      ~cmti_obj_dir
      ~(extra_libs : Lib.t list Memo.t)
      ~(extra_packages : Package.Name.t list Memo.t)
  =
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
  Odoc_artifact.create
    ~kind
    ~source:(Local_source source_file)
    ~extra_libs
    ~extra_packages
;;

let discover_local_lib_artifacts sctx ctx ~lib_name ~local_lib
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
  (* Get extras from odoc-config for libraries with packages, empty for private libs.
     Also include the library's own package in extra_packages.
     These are Memo.t values - computation is deferred until accessed. *)
  let extra_libs, extra_packages =
    match pkg with
    | None -> Memo.return [], Memo.return []
    | Some pkg ->
      let config_lazy = Memo.lazy_ (fun () -> resolve_pkg_doc_deps ctx ~pkg) in
      ( Memo.Lazy.force config_lazy >>| fst
      , Memo.Lazy.force config_lazy >>| fun (_, pkgs) -> pkg :: pkgs )
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
    List.concat_map modules ~f:(fun module_ ->
      let cmti_obj_dir =
        match vlib_obj_dir with
        | Some _ when Module.file module_ ~ml_kind:Intf <> None -> vlib_obj_dir
        | _ -> None
      in
      let mod_artifact =
        create_artifact_module
          ~target
          ~local_lib
          ~module_
          ~cmti_obj_dir
          ~extra_libs
          ~extra_packages
      in
      [ mod_artifact ])
  in
  Memo.return artifacts
;;

let toplevel_index_artifact ctx =
  let output_path = Odoc_paths.toplevel_index_mld ctx in
  let page = { Odoc_target.name = "index"; pkg_libs = [] } in
  let kind = Odoc_artifact.Page (page, Odoc_target.Toplevel) in
  let* items = Toplevel_index.get_items ctx in
  let content = Toplevel_index.mld_content items in
  let source = Odoc_artifact.Generated { content; output_path } in
  let package_names =
    List.map items ~f:(fun (Toplevel_index.Package { name; _ }) ->
      Package.Name.of_string name)
  in
  let extra_libs =
    Memo.lazy_ (fun () ->
      Memo.List.concat_map package_names ~f:(fun pkg -> libs_of_pkg ctx ~pkg))
    |> Memo.Lazy.force
  in
  let extra_packages = Memo.return package_names in
  Memo.return (Odoc_artifact.create ~kind ~source ~extra_libs ~extra_packages)
;;

let discover_pkg_mld_artifacts
      ~pkg
      ~pkg_libs
      ~mld_infos
      ~(extra_libs : Lib.t list Memo.t)
      ~(extra_packages : Package.Name.t list Memo.t)
  =
  let target = Odoc_target.Pkg pkg in
  let mld_artifacts =
    List.map mld_infos ~f:(fun (source, name) ->
      let page = { Odoc_target.name; pkg_libs } in
      let kind = Odoc_artifact.Page (page, target) in
      Odoc_artifact.create ~kind ~source ~extra_libs ~extra_packages)
  in
  let has_index = List.exists mld_infos ~f:(fun (_, name) -> String.equal name "index") in
  mld_artifacts, has_index, mld_infos
;;

let create_pkg_index_artifact
      ctx
      ~pkg
      ~pkg_libs
      ~lib_artifacts
      ~(extra_libs : Lib.t list Memo.t)
      ~(extra_packages : Package.Name.t list Memo.t)
  =
  let target = Odoc_target.Pkg pkg in
  let output_path = Odoc_paths.gen_mld_dir ctx pkg ++ "index.mld" in
  let page = { Odoc_target.name = "index"; pkg_libs } in
  let kind = Odoc_artifact.Page (page, target) in
  let content = default_pkg_index ~pkg ~lib_artifacts in
  let source = Odoc_artifact.Generated { content; output_path } in
  Odoc_artifact.create ~kind ~source ~extra_libs ~extra_packages
;;

let create_lib_index_artifact
      ctx
      ~pkg
      ~pkg_libs
      ~lib_name
      ~lib_artifacts
      ~extra_libs
      ~extra_packages
  =
  let target = Odoc_target.Pkg pkg in
  let lib_index_name = sprintf "%s/index" (Lib_name.to_string lib_name) in
  let output_path = Odoc_paths.lib_index_mld ctx pkg lib_name in
  let page = { Odoc_target.name = lib_index_name; pkg_libs } in
  let kind = Odoc_artifact.Page (page, target) in
  let content = library_index_content_from_artifacts ~lib_name ~artifacts:lib_artifacts in
  let source = Odoc_artifact.Generated { content; output_path } in
  Odoc_artifact.create ~kind ~source ~extra_libs ~extra_packages
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
      (* Installed libraries have no doc-only deps to follow (those used to come
         from odoc-config.sexp; that mechanism has been removed). *)
      let extra_libs = Memo.return [] in
      let extra_packages = Memo.return [] in
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
                ~extra_libs
                ~extra_packages
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

let discover_pkg_artifacts_common
      sctx
      ctx
      ~pkg
      ~libs
      ~mld_infos
      ~extra_libs
      ~extra_packages
      ~generate_lib_indices
  =
  let lib_subdirs = List.map libs ~f:(fun lib -> Lib.name lib |> Lib_name.to_string) in
  let mld_artifacts, has_pkg_index, mld_infos =
    discover_pkg_mld_artifacts ~pkg ~pkg_libs:libs ~mld_infos ~extra_libs ~extra_packages
  in
  let* lib_artifacts = discover_all_lib_artifacts sctx ctx ~pkg ~libs in
  let pkg_index_artifact =
    if has_pkg_index
    then []
    else
      [ create_pkg_index_artifact
          ctx
          ~pkg
          ~pkg_libs:libs
          ~lib_artifacts
          ~extra_libs
          ~extra_packages
      ]
  in
  let lib_index_artifacts =
    if not generate_lib_indices
    then []
    else
      List.filter_map lib_artifacts ~f:(fun (lib, artifacts) ->
        let lib_name = Lib.name lib in
        let lib_index_name = sprintf "%s/index" (Lib_name.to_string lib_name) in
        let has_source_lib_index =
          List.exists mld_infos ~f:(fun (_, name) -> String.equal name lib_index_name)
        in
        if has_source_lib_index
        then None
        else
          Some
            (create_lib_index_artifact
               ctx
               ~pkg
               ~pkg_libs:libs
               ~lib_name
               ~lib_artifacts:artifacts
               ~extra_libs
               ~extra_packages))
  in
  let all_module_artifacts = List.concat_map lib_artifacts ~f:snd in
  let all_artifacts =
    mld_artifacts @ pkg_index_artifact @ lib_index_artifacts @ all_module_artifacts
  in
  Memo.return (all_artifacts, lib_subdirs)
;;

let create_private_lib_index_artifact ctx ~lib_unique_name ~lib_name ~lib_artifacts =
  let dummy_pkg = Package.Name.of_string lib_unique_name in
  let output_path = Odoc_paths.gen_mld_dir ctx dummy_pkg ++ "index.mld" in
  let page = { Odoc_target.name = "index"; pkg_libs = [] } in
  let kind = Odoc_artifact.Page (page, Odoc_target.Pkg dummy_pkg) in
  let content = library_index_content_from_artifacts ~lib_name ~artifacts:lib_artifacts in
  let source = Odoc_artifact.Generated { content; output_path } in
  Odoc_artifact.create
    ~kind
    ~source
    ~extra_libs:(Memo.return [])
    ~extra_packages:(Memo.return [])
;;

(* Discover artifacts for a private library.
   Takes the fields from Scope_id.Private_lib directly to make invalid calls impossible. *)
let discover_private_lib_artifacts sctx ctx ~lib_unique_name ~lib_name ~project
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
    let* module_artifacts = discover_local_lib_artifacts sctx ctx ~lib_name ~local_lib in
    let index_artifact =
      create_private_lib_index_artifact
        ctx
        ~lib_unique_name
        ~lib_name
        ~lib_artifacts:module_artifacts
    in
    let artifacts = index_artifact :: module_artifacts in
    (* Private libraries don't have subdirectories in the same sense as packages *)
    Memo.return (artifacts, [])
;;

let discover_local_pkg_artifacts sctx ctx ~pkg
  : (Odoc_artifact.t list * string list) Memo.t
  =
  let* all_libs = libs_of_pkg ctx ~pkg in
  let libs =
    List.filter_map all_libs ~f:(fun lib ->
      Option.map (Lib.Local.of_lib lib) ~f:Lib.Local.to_lib)
  in
  let config_lazy = Memo.lazy_ (fun () -> resolve_pkg_doc_deps ctx ~pkg) in
  let extra_libs = Memo.Lazy.force config_lazy >>| fst in
  let extra_packages = Memo.Lazy.force config_lazy >>| snd in
  let* mld_infos = get_local_mld_infos sctx ~pkg in
  let* base_artifacts, lib_subdirs =
    discover_pkg_artifacts_common
      sctx
      ctx
      ~pkg
      ~libs
      ~mld_infos
      ~extra_libs
      ~extra_packages
      ~generate_lib_indices:true
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
  (* Installed packages have no doc-only deps to follow (those used to come
     from odoc-config.sexp; that mechanism has been removed). *)
  let extra_libs = Memo.return [] in
  let extra_packages = Memo.return [] in
  let mld_files = Package_discovery.mlds_of_package pkg_discovery pkg in
  let mld_infos =
    List.map mld_files ~f:(fun (mld_path, _dst) ->
      let name = page_name_from_installed_mld_path mld_path in
      let source = Odoc_artifact.Installed_source { src_path = mld_path } in
      source, name)
  in
  discover_pkg_artifacts_common
    sctx
    ctx
    ~pkg
    ~libs
    ~mld_infos
    ~extra_libs
    ~extra_packages
    ~generate_lib_indices:false
;;

let discover_package_artifacts sctx ctx ~pkg_or_lib_unique_name
  : (Odoc_artifact.t list * string list) Memo.t
  =
  let* scope_id = Odoc_scope.Scope_id.of_string pkg_or_lib_unique_name in
  match scope_id with
  | Odoc_scope.Scope_id.Private_lib { unique_name; lib_name; project } ->
    discover_private_lib_artifacts
      sctx
      ctx
      ~lib_unique_name:unique_name
      ~lib_name
      ~project
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
  let* toplevel_artifact = toplevel_index_artifact ctx in
  let toplevel_odocl = Odoc_artifact.odocl_file ctx toplevel_artifact in
  let all_odocl_files = toplevel_odocl :: pkg_odocl_files in
  Memo.return (workspace_pkgs, all_odocl_files)
;;
