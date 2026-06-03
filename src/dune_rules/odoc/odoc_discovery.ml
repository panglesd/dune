open Import
open Memo.O

let ( ++ ) = Path.Build.relative

let libs_of_pkg ctx ~pkg =
  let+ { Scope.DB.Lib_entry.Set.libraries; _ } =
    Scope.DB.lib_entries_of_package ctx pkg
  in
  (* Filter out all implementations of virtual libraries *)
  List.filter_map libraries ~f:(fun lib ->
    match Lib.Local.to_lib lib |> Lib.info |> Lib_info.implements with
    | None -> Some lib
    | Some _ -> None)
;;

(* All local libraries in the workspace (across all projects), excluding
   implementations of virtual libraries. Used to build the single global search
   database that indexes every documented artifact. *)
let all_local_libs sctx =
  let ctx = Super_context.context sctx in
  let* projects = Dune_load.projects () in
  let* lib_sets =
    Scope.DB.with_all ctx ~f:(fun find ->
      Memo.List.map projects ~f:(fun proj -> Lib.DB.all (Scope.libs (find proj))))
  in
  let+ lib_sets = lib_sets in
  List.fold_left lib_sets ~init:Lib.Set.empty ~f:Lib.Set.union
  |> Lib.Set.to_list
  |> List.filter_map ~f:(fun lib ->
    match Lib.Local.of_lib lib with
    | None -> None
    | Some l ->
      if Option.is_some (Lib_info.implements (Lib.info lib)) then None else Some l)
;;

let entry_modules_by_lib sctx lib =
  let info = Lib.Local.info lib in
  let { Compilation_mode.for_merlin; _ } =
    Compilation_mode.of_mode_set (Lib_info.modes info)
  in
  Dir_contents.modules_of_local_lib sctx lib ~for_:for_merlin >>| Modules.entry_modules
;;

(* Archive basenames of a library, used to filter [odoc classify] output.
   Installed libraries built by the compiler (e.g. [stdlib]) record no archive,
   so [stdlib] is special-cased. *)
let get_archive_names lib_name archives =
  match Mode.Dict.get archives Mode.Byte with
  | [] ->
    if Lib_name.equal lib_name (Lib_name.of_string "stdlib") then [ "stdlib" ] else []
  | archives ->
    List.map archives ~f:(fun p ->
      Path.basename p |> Filename.remove_extension |> Filename.to_string)
;;

(* Module names belonging to [archive_names] in [odoc classify] output (one
   ["<archive> <Mod> <Mod> ..."] line per archive). *)
let parse_classify_output ~archive_names content =
  String.split_lines content
  |> List.concat_map ~f:(fun line ->
    match
      String.split line ~on:' ' |> List.filter ~f:(fun s -> not (String.is_empty s))
    with
    | [] -> []
    | archive :: mods ->
      if List.mem archive_names archive ~equal:String.equal then mods else [])
;;

(* A module of an external library, as discovered by [odoc classify]. *)
type ext_module =
  { name : Module_name.t
  ; cmti : Path.t (** Source [.cmti]/[.cmi] in the install directory. *)
  ; odoc_file : Path.Build.t
  }

(* Modules of an external (installed) library, discovered from the [odoc
   classify] output. Reading the classify file builds it on demand. *)
let external_lib_modules sctx lib =
  let ctx = Super_context.context sctx in
  let info = Lib.info lib in
  let archive_names = get_archive_names (Lib.name lib) (Lib_info.archives info) in
  if List.is_empty archive_names
  then Memo.return []
  else
    let* content =
      Build_system.read_file (Path.build (Odoc_paths.classify_file ctx lib))
    in
    let src_dir = Lib_info.src_dir info in
    let doc_dir = Odoc_paths.odocs ctx (Odoc_target.Ext_lib lib) in
    parse_classify_output ~archive_names content
    |> List.map ~f:(fun name ->
      let module_name = Module_name.of_checked_string name in
      let base = Module_name.uncapitalize module_name in
      let cmti = Path.relative src_dir (base ^ ".cmti") in
      let odoc_file = Path.Build.relative doc_dir (base ^ ".odoc") in
      { name = module_name; cmti; odoc_file })
    |> Memo.List.filter_map ~f:(fun m ->
      let+ cmti_exists = Fs_memo.file_exists (Path.as_outside_build_dir_exn m.cmti) in
      if cmti_exists
      then Some m
      else (
        let cmi =
          Path.set_extension m.cmti ~ext:(Filename.Extension.of_string_exn ".cmi")
        in
        Some { m with cmti = cmi }))
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
    let+ modules = entry_modules_by_lib sctx lib in
    List.map modules ~f:(fun m ->
      Odoc_paths.lib_module_odoc ctx lib m |> Odoc_artifact.make ~target)
  | Odoc_target.Ext_lib lib ->
    let+ modules = external_lib_modules sctx lib in
    List.map modules ~f:(fun m -> Odoc_artifact.make ~target m.odoc_file)
;;

let sp = Printf.sprintf

module Toplevel_index = struct
  type item =
    { name : string
    ; version : Package_version.t option
    ; link : string
    }

  let of_packages packages output_format =
    Package.Name.Map.to_list_map packages ~f:(fun name package ->
      let name = Package.Name.to_string name in
      let extension =
        match (output_format : Odoc_paths.output_format) with
        | Odoc_paths.Markdown -> "md"
        | Odoc_paths.Html | Odoc_paths.Json -> "html"
      in
      { name; version = Package.version package; link = sp "%s/index.%s" name extension })
  ;;

  let html_list_items t =
    List.map t ~f:(fun { name; version; link } ->
      let link = sp {|<a href="%s">%s</a>|} link name in
      let version_suffix =
        match version with
        | None -> ""
        | Some v -> sp {| <span class="version">%s</span>|} (Package_version.to_string v)
      in
      sp "<li>%s%s</li>" link version_suffix)
    |> String.concat ~sep:"\n      "
  ;;

  let html t =
    sp
      {|<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>index</title>
    <link rel="stylesheet" href="./%s/odoc.css"/>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  </head>
  <body>
    <main class="content">
      <div class="by-name">
      <h2>OCaml package documentation</h2>
      <ol>
      %s
      </ol>
      </div>
    </main>
  </body>
</html>|}
      Odoc_paths.odoc_support_dirname
      (html_list_items t)
  ;;

  let string_to_json s = `String s
  let list_to_json ~f l = `List (List.map ~f l)

  let option_to_json ~f = function
    | None -> `Null
    | Some x -> f x
  ;;

  let item_to_json { name; version; link } =
    `Assoc
      [ "name", string_to_json name
      ; ( "version"
        , Option.map ~f:Package_version.to_string version
          |> option_to_json ~f:string_to_json )
      ; "link", string_to_json link
      ]
  ;;

  (** This format is public API. *)
  let to_json items = `Assoc [ "packages", list_to_json items ~f:item_to_json ]

  let json t = Json.to_string (to_json t)

  let markdown t =
    let b = Buffer.create 256 in
    Buffer.add_string b "# OCaml Package Documentation\n\n";
    List.iter t ~f:(fun { name; version; link } ->
      Buffer.add_string b (sp "- [%s](%s)" name link);
      (match version with
       | None -> ()
       | Some v -> Buffer.add_string b (sp " (version %s)" (Package_version.to_string v)));
      Buffer.add_char b '\n');
    Buffer.contents b
  ;;

  let content (output : Odoc_paths.output_format) t =
    match output with
    | Odoc_paths.Html -> html t
    | Odoc_paths.Json -> json t
    | Odoc_paths.Markdown -> markdown t
  ;;
end

let default_index ~pkg entry_modules =
  let b = Buffer.create 512 in
  Printf.bprintf b "{0 %s index}\n" (Package.Name.to_string pkg);
  Lib.Local.Map.to_list entry_modules
  |> List.sort ~compare:(fun (x, _) (y, _) ->
    let name lib = Lib.name (Lib.Local.to_lib lib) in
    Lib_name.compare (name x) (name y))
  |> List.iter ~f:(fun (lib, modules) ->
    let lib = Lib.Local.to_lib lib in
    Printf.bprintf b "{1 Library %s}\n" (Lib_name.to_string (Lib.name lib));
    Buffer.add_string
      b
      (match modules with
       | [ x ] ->
         sprintf
           "The entry point of this library is the module:\n{!module-%s}.\n"
           (Module_name.to_string (Module.name x))
       | _ ->
         sprintf
           "This library exposes the following toplevel modules:\n{!modules:%s}\n"
           (modules
            |> List.filter ~f:(fun m -> Module.visibility m = Visibility.Public)
            |> List.sort ~compare:(fun x y ->
              Module_name.compare (Module.name x) (Module.name y))
            |> List.map ~f:(fun m -> Module_name.to_string (Module.name m))
            |> String.concat ~sep:" ")));
  Buffer.contents b
;;
