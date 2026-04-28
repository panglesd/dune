open Import
open Memo.O
module Ext_loc_map = Map.Make (Dune_package.External_location)

type t =
  { findlib_paths : int Path.Map.t
  ; loc_of_pkg : Dune_package.External_location.t Package.Name.Map.t
  ; loc_of_lib : Dune_package.External_location.t Lib_name.Map.t
  ; libs_of_loc : (Dune_package.Lib.t * Lib.t) Lib_name.Map.t Ext_loc_map.t
  ; mlds_of_pkg : (Path.t * string) list Package.Name.Map.t
  }

let empty =
  { findlib_paths = Path.Map.empty
  ; loc_of_pkg = Package.Name.Map.empty
  ; loc_of_lib = Lib_name.Map.empty
  ; libs_of_loc = Ext_loc_map.empty
  ; mlds_of_pkg = Package.Name.Map.empty
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
             let loc_of_pkg =
               match pkg, location_opt with
               | Some pkg_name, Some location ->
                 (match Package.Name.Map.add maps.loc_of_pkg pkg_name location with
                  | Ok m -> m
                  | Error _ -> maps.loc_of_pkg)
               | _ -> maps.loc_of_pkg
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
             { maps with loc_of_lib; loc_of_pkg; libs_of_loc }))
  in
  let+ mlds_of_pkg =
    Package.Name.Map.foldi
      maps.loc_of_pkg
      ~init:(Memo.return Package.Name.Map.empty)
      ~f:(fun pkg _loc acc ->
        let* acc = acc in
        Findlib.find_root_package findlib pkg
        >>| function
        | Error _ -> acc
        | Ok dpkg ->
          let mlds = mlds_of_dune_package dpkg in
          if List.is_empty mlds then acc else Package.Name.Map.set acc pkg mlds)
  in
  { maps with mlds_of_pkg }
;;

let create =
  let memo = Memo.create "package-discovery" ~input:(module Context) build in
  fun ~context -> Memo.exec memo context
;;

let mlds_of_package t pkg =
  Package.Name.Map.find t.mlds_of_pkg pkg |> Option.value ~default:[]
;;

let findlib_paths t = t.findlib_paths
let location_of_package t pkg = Package.Name.Map.find t.loc_of_pkg pkg
let location_of_library t lib = Lib_name.Map.find t.loc_of_lib lib
let libs_of_location t = t.libs_of_loc
