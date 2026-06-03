open Import
open Memo.O

let ( ++ ) = Path.Build.relative

let libs_of_pkg ctx ~pkg =
  let+ { Scope.DB.Lib_entry.Set.libraries; _ } = Scope.DB.lib_entries_of_package ctx pkg in
  (* Filter out all implementations of virtual libraries *)
  List.filter_map libraries ~f:(fun lib ->
    match Lib.Local.to_lib lib |> Lib.info |> Lib_info.implements with
    | None -> Some lib
    | Some _ -> None)
;;

let entry_modules_by_lib sctx lib =
  let info = Lib.Local.info lib in
  let { Compilation_mode.for_merlin; _ } =
    Compilation_mode.of_mode_set (Lib_info.modes info)
  in
  Dir_contents.modules_of_local_lib sctx lib ~for_:for_merlin >>| Modules.entry_modules
;;

let entry_modules sctx ~pkg =
  let* l =
    Super_context.context sctx
    |> Context.name
    |> libs_of_pkg ~pkg
    >>| List.filter ~f:(fun lib ->
      Lib.Local.info lib |> Lib_info.status |> Lib_info.Status.is_private |> not)
  in
  let+ l =
    Memo.parallel_map l ~f:(fun l ->
      let+ m = entry_modules_by_lib sctx l in
      l, m)
  in
  Lib.Local.Map.of_list_exn l
;;

let mld_ext = Filename.Extension.of_string_exn ".mld"

let check_mlds_no_dupes ~pkg ~mlds =
  match
    List.rev_map mlds ~f:(fun ((_path, mld_name) as mld) -> mld_name, mld)
    |> String.Map.of_list
  with
  | Ok m -> m
  | Error (_, (p1, _name1), (p2, _name2)) ->
    User_error.raise
      [ Pp.textf
          "Package %s has two mld's with the same basename %s, %s"
          (Package.Name.to_string pkg)
          (Path.to_string_maybe_quoted (Path.build p1))
          (Path.to_string_maybe_quoted (Path.build p2))
      ]
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

let odoc_ext = ".odoc"

module Mld : sig
  type t

  val create : path:Path.Build.t -> name:string -> t
  val odoc_file : doc_dir:Path.Build.t -> t -> Path.Build.t
  val odoc_input : t -> Path.Build.t
end = struct
  (** The [(documentation (files ...))] stanza allows with the [as] keyword to
      distinguish the input file and the path in the documentation. Here we do
      not support layered hierarchy, but we do support changing the name (hence
      the two fields) *)
  type t =
    { path : Path.Build.t
    ; name : string (** The name of the mld compilation unit (without extension) *)
    }

  let create ~path ~name = { path; name }

  let odoc_file ~doc_dir { name; _ } =
    Path.Build.relative doc_dir (sprintf "page-%s%s" name odoc_ext)
  ;;

  let odoc_input { path; _ } = path
end

let odoc_artefacts sctx target =
  let ctx = Super_context.context sctx in
  let dir = Odoc_paths.odocs ctx target in
  match target with
  | Odoc_target.Pkg pkg ->
    let+ mlds =
      let+ mlds, _ = mlds sctx pkg in
      let mlds = check_mlds_no_dupes ~pkg ~mlds in
      String.Map.update mlds "index" ~f:(function
        | None -> Some (Odoc_paths.gen_mld_dir ctx pkg ++ "index.mld", "index")
        | Some _ as s -> s)
    in
    String.Map.to_list_map mlds ~f:(fun _ (path, name) ->
      Mld.create ~path ~name |> Mld.odoc_file ~doc_dir:dir |> Odoc_artifact.make ~target)
  | Odoc_target.Lib lib ->
    let info = Lib.Local.info lib in
    let obj_dir = Lib_info.obj_dir info in
    let+ modules = entry_modules_by_lib sctx lib in
    List.map modules ~f:(fun m -> Obj_dir.Module.odoc obj_dir m |> Odoc_artifact.make ~target)
;;
