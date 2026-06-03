open Import
open Memo.O

type t =
  { findlib : Findlib.t
  ; libs_of_pkg : Lib.t list Package.Name.Map.t
  }

let build context =
  let* findlib = Findlib.create (Context.name context) in
  let* installed = Lib.DB.installed context in
  let+ all = Lib.DB.all installed in
  let libs_of_pkg =
    Lib.Set.fold all ~init:Package.Name.Map.empty ~f:(fun lib acc ->
      (* implementations of virtual libraries have no documentation of their own *)
      match Lib_info.implements (Lib.info lib) with
      | Some _ -> acc
      | None ->
        (match Lib_info.package (Lib.info lib) with
         | None -> acc
         | Some pkg -> Package.Name.Map.add_multi acc pkg lib))
  in
  { findlib; libs_of_pkg }
;;

let create =
  let memo = Memo.create "package-discovery" ~input:(module Context) build in
  fun ~context -> Memo.exec memo context
;;

let libraries_of_package t pkg =
  Package.Name.Map.find t.libs_of_pkg pkg |> Option.value ~default:[]
;;

(* The installed [.mld] documentation pages of a package, as
   [(source_path, page_name)] pairs, read from its dune-package's Doc section. *)
let mlds_of_dune_package (dpkg : Dune_package.t) =
  match Section.Map.find dpkg.sections Section.Doc with
  | None -> []
  | Some doc_path ->
    List.concat_map dpkg.files ~f:(fun (section, files) ->
      match (section : Section.t) with
      | Doc ->
        List.filter_map files ~f:(fun (entry : Dune_package.path) ->
          match entry.kind with
          | Install.Entry.Expanded.File ->
            let dst = Install.Entry.Dst.to_string entry.dst in
            if String.ends_with dst ~suffix:".mld"
            then (
              let name =
                Stdlib.Filename.basename dst |> Stdlib.Filename.remove_extension
              in
              Some (Path.relative doc_path dst, name))
            else None
          | Directory -> None)
      | _ -> [])
;;

let mlds_of_package t pkg =
  Findlib.find_root_package t.findlib pkg
  >>| function
  | Error _ -> []
  | Ok dpkg -> mlds_of_dune_package dpkg
;;

let version_of_package t pkg =
  Findlib.find_root_package t.findlib pkg
  >>| function
  | Error _ -> None
  | Ok (dpkg : Dune_package.t) -> Option.map dpkg.version ~f:Package_version.to_string
;;
