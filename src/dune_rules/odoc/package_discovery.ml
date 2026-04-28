open Import
open Memo.O
module Ext_loc_map = Map.Make (Dune_package.External_location)

type t =
  { findlib_paths : int Path.Map.t
  ; loc_of_pkg : Dune_package.External_location.t Package.Name.Map.t
  ; loc_of_lib : Dune_package.External_location.t Lib_name.Map.t
  ; libs_of_loc : (Dune_package.Lib.t * Lib.t) Lib_name.Map.t Ext_loc_map.t
  ; pkg_of_lib : Package.Name.t Lib_name.Map.t
  ; libs_of_pkg : Lib.t list Package.Name.Map.t
  ; mlds_of_pkg : (Path.t * string) list Package.Name.Map.t
  ; module_files_of_lib : Path.t Module_name.Map.t Lib_name.Map.t
  ; config_of_pkg : Odoc_config.t Package.Name.Map.t
  }

let empty =
  { findlib_paths = Path.Map.empty
  ; loc_of_pkg = Package.Name.Map.empty
  ; loc_of_lib = Lib_name.Map.empty
  ; libs_of_loc = Ext_loc_map.empty
  ; pkg_of_lib = Lib_name.Map.empty
  ; libs_of_pkg = Package.Name.Map.empty
  ; mlds_of_pkg = Package.Name.Map.empty
  ; module_files_of_lib = Lib_name.Map.empty
  ; config_of_pkg = Package.Name.Map.empty
  }
;;

let mlds_of_dune_package (dpkg : Dune_package.t) =
  match Section.Map.find dpkg.sections Doc with
  | None -> []
  | Some doc_path ->
    List.concat_map dpkg.files ~f:(fun (section, files) ->
      match section with
      | Dune_section.Doc ->
        List.filter_map files ~f:(fun (entry : Dune_package.path) ->
          match entry.kind with
          | File ->
            let str = Install.Entry.Dst.to_string entry.dst in
            if String.ends_with ~suffix:".mld" str
            then Some (Path.relative doc_path str, str)
            else None
          | Directory -> None)
      | _ -> [])
;;

(* Scan an install directory and return a [module_name -> file] map for
   every [.cmti] (preferred) or [.cmt] found.  Mirrors
   [odoc_new.modules_of_dir]. *)
let module_files_in_dir dir =
  Fs_memo.dir_contents (Path.as_outside_build_dir_exn dir)
  >>| function
  | Error _ -> Module_name.Map.empty
  | Ok dc ->
    let entries = Fs_memo.Dir_contents.to_list dc in
    let extension_priority ext =
      match Filename.Extension.Or_empty.to_string ext with
      | ".cmti" -> Some 0
      | ".cmt" -> Some 1
      | _ -> None
    in
    List.fold_left entries ~init:Module_name.Map.empty ~f:(fun acc (name, kind) ->
      match kind with
      | Unix.S_REG ->
        let ext = Filename.extension name in
        (match extension_priority ext with
         | None -> acc
         | Some prio ->
           let base = Filename.remove_extension name in
           (match Module_name.of_string_user_error (Loc.none, base) with
            | Error _ -> acc
            | Ok mod_name ->
              let path = Path.relative dir name in
              Module_name.Map.update acc mod_name ~f:(function
                | None -> Some (prio, path)
                | Some (existing_prio, _) when prio < existing_prio -> Some (prio, path)
                | Some _ as keep -> keep)))
      | _ -> acc)
    |> Module_name.Map.map ~f:snd
;;

let build (ctx : Context.t) =
  let* installed_libs = Lib.DB.installed ctx in
  let* all_libs_set = Lib.DB.all installed_libs in
  let lib_names = Lib.Set.to_list all_libs_set |> List.map ~f:Lib.name in
  let* db = Scope.DB.public_libs (Context.name ctx) in
  let* findlib = Findlib.create (Context.name ctx) in
  let* all_packages_entries =
    Memo.parallel_map lib_names ~f:(Findlib.find findlib)
    >>| List.filter_map ~f:Result.to_option
  in
  let* findlib_paths =
    let+ findlib_paths_list = Context.findlib_paths ctx in
    List.fold_left findlib_paths_list ~init:(0, Path.Map.empty) ~f:(fun (i, acc) path ->
      let acc =
        match Path.Map.add acc path i with
        | Ok acc -> acc
        | Error _ -> acc
      in
      i + 1, acc)
    |> snd
  in
  let* maps =
    Memo.List.fold_left
      all_packages_entries
      ~init:{ empty with findlib_paths }
      ~f:(fun maps entry ->
        match (entry : Dune_package.Entry.t) with
        | Deprecated_library_name _ | Hidden_library _ -> Memo.return maps
        | Library l ->
          let info = Dune_package.Lib.info l in
          let name = Lib_info.name info in
          let pkg = Lib_info.package info in
          Lib.DB.find_lib_id db (Lib_info.lib_id info)
          >>| (function
           | None -> maps
           | Some lib ->
             let location_opt = Dune_package.Lib.external_location l in
             let loc_of_lib =
               match location_opt with
               | None -> maps.loc_of_lib
               | Some location ->
                 (match Lib_name.Map.add maps.loc_of_lib name location with
                  | Ok m -> m
                  | Error _ -> maps.loc_of_lib)
             in
             let loc_of_pkg, pkg_of_lib, libs_of_pkg =
               match pkg with
               | None -> maps.loc_of_pkg, maps.pkg_of_lib, maps.libs_of_pkg
               | Some pkg_name ->
                 let loc_of_pkg =
                   match location_opt with
                   | None -> maps.loc_of_pkg
                   | Some location ->
                     (match Package.Name.Map.add maps.loc_of_pkg pkg_name location with
                      | Ok m -> m
                      | Error _ -> maps.loc_of_pkg)
                 in
                 let pkg_of_lib = Lib_name.Map.set maps.pkg_of_lib name pkg_name in
                 let libs_of_pkg =
                   Package.Name.Map.update maps.libs_of_pkg pkg_name ~f:(function
                     | None -> Some [ lib ]
                     | Some libs -> Some (lib :: libs))
                 in
                 loc_of_pkg, pkg_of_lib, libs_of_pkg
             in
             let libs_of_loc =
               match location_opt with
               | None -> maps.libs_of_loc
               | Some location ->
                 Ext_loc_map.update maps.libs_of_loc location ~f:(function
                   | None -> Some (Lib_name.Map.singleton name (l, lib))
                   | Some libs ->
                     (match Lib_name.Map.add libs name (l, lib) with
                      | Ok libs -> Some libs
                      | Error _ -> Some libs))
             in
             { maps with loc_of_lib; loc_of_pkg; libs_of_loc; pkg_of_lib; libs_of_pkg }))
  in
  let* mlds_of_pkg, config_of_pkg =
    Package.Name.Map.foldi
      maps.libs_of_pkg
      ~init:(Memo.return (Package.Name.Map.empty, Package.Name.Map.empty))
      ~f:(fun pkg _libs acc ->
        let* mlds_acc, configs_acc = acc in
        Findlib.find_root_package findlib pkg
        >>| function
        | Error _ -> mlds_acc, configs_acc
        | Ok dpkg ->
          let mlds_acc =
            let mlds = mlds_of_dune_package dpkg in
            if List.is_empty mlds
            then mlds_acc
            else Package.Name.Map.set mlds_acc pkg mlds
          in
          let configs_acc =
            match Section.Map.find dpkg.sections Doc with
            | None -> configs_acc
            | Some doc_path ->
              let cfg_path =
                Path.relative
                  doc_path
                  (sprintf "%s/odoc-config.sexp" (Package.Name.to_string pkg))
              in
              Package.Name.Map.set configs_acc pkg (Odoc_config.load cfg_path)
          in
          mlds_acc, configs_acc)
  in
  (* Build module_files_of_lib: scan each installed lib's src_dir. *)
  let* module_files_of_lib =
    Lib_name.Map.foldi
      maps.pkg_of_lib
      ~init:(Memo.return Lib_name.Map.empty)
      ~f:(fun lib_name _pkg acc ->
        let* acc = acc in
        Lib.DB.find installed_libs lib_name
        >>= function
        | None -> Memo.return acc
        | Some lib ->
          let src_dir = Lib_info.src_dir (Lib.info lib) in
          let+ files = module_files_in_dir src_dir in
          if Module_name.Map.is_empty files
          then acc
          else Lib_name.Map.set acc lib_name files)
  in
  Memo.return { maps with mlds_of_pkg; module_files_of_lib; config_of_pkg }
;;

let create =
  let memo = Memo.create "package-discovery" ~input:(module Context) build in
  fun ~context -> Memo.exec memo context
;;

let package_of_library t lib =
  (match Lib.Local.of_lib lib with
   | Some _ ->
     Code_error.raise
       "Package_discovery.package_of_library called on local library"
       [ "lib", Lib_name.to_dyn (Lib.name lib) ]
   | None -> ());
  Lib_name.Map.find t.pkg_of_lib (Lib.name lib)
;;

let libraries_of_package t pkg =
  Package.Name.Map.find t.libs_of_pkg pkg |> Option.value ~default:[]
;;

let mlds_of_package t pkg =
  Package.Name.Map.find t.mlds_of_pkg pkg |> Option.value ~default:[]
;;

let module_source_file t ~lib ~module_name =
  let lib_name = Lib.name lib in
  let mod_name =
    match Module_name.of_string_user_error (Loc.none, module_name) with
    | Ok m -> Some m
    | Error _ -> None
  in
  let open Option.O in
  let* mod_name = mod_name in
  let* lib_modules = Lib_name.Map.find t.module_files_of_lib lib_name in
  Module_name.Map.find lib_modules mod_name
;;

let findlib_paths t = t.findlib_paths
let location_of_package t pkg = Package.Name.Map.find t.loc_of_pkg pkg
let location_of_library t lib = Lib_name.Map.find t.loc_of_lib lib
let libs_of_location t = t.libs_of_loc

let config_of_package t pkg =
  Package.Name.Map.find t.config_of_pkg pkg |> Option.value ~default:Odoc_config.empty
;;
