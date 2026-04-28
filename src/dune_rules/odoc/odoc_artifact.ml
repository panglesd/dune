open Import

let ( ++ ) = Path.Build.relative

type kind =
  | Module : Odoc_target.mod_ * Odoc_target.mod_ Odoc_target.t -> kind
  | Page : Odoc_target.page * Odoc_target.page Odoc_target.t -> kind

type source = Local_source of Path.Build.t

type t =
  { kind : kind
  ; source : source
  }

let get_kind t = t.kind

let source_file t =
  match t.source with
  | Local_source path -> Path.build path
;;

let pkg t =
  match t.kind with
  | Module (_, Lib local_lib) -> Lib_info.package (Lib.Local.info local_lib)
  | Page (_, Pkg pkg) -> Some pkg
;;

let lib t =
  match t.kind with
  | Module (_, Lib local_lib) -> Some (Lib.Local.to_lib local_lib)
  | Page _ -> None
;;

let lib_name t =
  match t.kind with
  | Module (_, Lib local_lib) -> Lib.name (Lib.Local.to_lib local_lib)
  | Page (_, Pkg pkg) -> Lib_name.of_string (Package.Name.to_string pkg)
;;

let odoc_dir ctx t =
  match t.kind with
  | Module (_, target) -> Odoc_paths.odocs ctx target
  | Page (_, target) -> Odoc_paths.odocs ctx target
;;

let split_page_name name =
  match String.rsplit2 name ~on:'/' with
  | Some (parent, leaf) -> Some parent, leaf
  | None -> None, name
;;

let get_basename t =
  match t.kind, t.source with
  | Page (page, _), _ -> snd (split_page_name page.name)
  | Module (_, _), Local_source src_path ->
    Path.Build.basename src_path |> Filename.remove_extension
;;

let odoc_file ctx t =
  let basename = get_basename t in
  match t.kind with
  | Page (page, target) ->
    let base_dir = Odoc_paths.odocs ctx target in
    (match fst (split_page_name page.name) with
     | Some parent_path -> base_dir ++ parent_path ++ ("page-" ^ basename ^ ".odoc")
     | None -> base_dir ++ ("page-" ^ basename ^ ".odoc"))
  | Module (_, target) ->
    let base_dir = Odoc_paths.odocs ctx target in
    base_dir ++ (basename ^ ".odoc")
;;

let odocl_file ctx t =
  let basename = get_basename t in
  match t.kind with
  | Page (page, target) ->
    let base_dir = Odoc_paths.odocl ctx target in
    (match fst (split_page_name page.name) with
     | Some parent_path -> base_dir ++ parent_path ++ ("page-" ^ basename ^ ".odocl")
     | None -> base_dir ++ ("page-" ^ basename ^ ".odocl"))
  | Module (_, target) ->
    let base_dir = Odoc_paths.odocl ctx target in
    base_dir ++ (basename ^ ".odocl")
;;

let output_base ctx format t =
  match t.kind with
  | Module (_, target) -> Odoc_paths.output ctx format target
  | Page (_, target) -> Odoc_paths.output ctx format target
;;

let output_extension : Odoc_paths.output_format -> string = function
  | Html -> ".html"
  | Json -> ".html.json"
  | Markdown -> ".md"
;;

let output_file ctx format t =
  let base = output_base ctx format t in
  let basename = get_basename t in
  let suffix = Filename.of_string_exn (Output_format.extension format) in
  match t.kind, (format : Odoc_paths.output_format) with
  | Module _, (Html | Json) ->
    let dir = base ++ Stdune.String.capitalize basename in
    dir ++ ("index" ^ suffix)
  | Module _, Markdown -> base ++ (Stdune.String.capitalize basename ^ suffix)
  | Page (page, _), _ ->
    let path =
      match fst (split_page_name page.name) with
      | Some parent_path -> base ++ parent_path ++ basename
      | None -> base ++ basename
    in
    Path.Build.extend_basename path ~suffix
;;

let hidden t =
  match t.kind with
  | Page _ -> false
  | Module _ ->
    let basename = get_basename t in
    String.contains_double_underscore basename
;;

let parent_id t =
  let base_id =
    match t.kind with
    | Module (_, Lib local_lib) ->
      let lib = Lib.Local.to_lib local_lib in
      (match Lib_info.package (Lib.info lib) with
       | Some pkg -> Package.Name.to_string pkg
       | None -> Odoc_scope.lib_unique_name local_lib)
    | Page (_, Pkg pkg) -> Package.Name.to_string pkg
  in
  match t.kind with
  | Module _ -> base_id
  | Page (page, _) ->
    (match fst (split_page_name page.name) with
     | Some parent_path -> sprintf "%s/%s" base_id parent_path
     | None -> base_id)
;;

let create ~kind ~source = { kind; source }
