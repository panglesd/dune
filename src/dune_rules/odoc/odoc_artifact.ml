open Import

let ( ++ ) = Path.Build.relative

type kind =
  | Module : Odoc_target.mod_ * Odoc_target.mod_ Odoc_target.t -> kind
  | Page : Odoc_target.page * Odoc_target.page Odoc_target.t -> kind
  | Asset : Odoc_target.asset * Odoc_target.page Odoc_target.t -> kind
  | Impl : Odoc_target.impl * Odoc_target.mod_ Odoc_target.t -> kind

type source =
  | Local_source of Path.Build.t
  | Installed_source of { src_path : Path.t }
  | Generated of
      { content : string
      ; output_path : Path.Build.t
      }

type t =
  { kind : kind
  ; source : source
  ; extra_libs : Lib.t list Memo.t
  ; extra_packages : Package.Name.t list Memo.t
  }

let get_kind t = t.kind
let extra_libs t = t.extra_libs
let extra_packages t = t.extra_packages

let source_file t =
  match t.source with
  | Local_source path -> Path.build path
  | Installed_source { src_path; _ } -> src_path
  | Generated { output_path; _ } -> Path.build output_path
;;

let generated_content t =
  match t.source with
  | Generated { content; _ } -> Some content
  | Local_source _ | Installed_source _ -> None
;;

let pkg t =
  match t.kind with
  | Module (_, Lib (pkg, _)) -> Some pkg
  | Module (_, Private_lib _) -> None
  | Impl (_, Lib (pkg, _)) -> Some pkg
  | Impl (_, Private_lib _) -> None
  | Page (_, Pkg pkg) -> Some pkg
  | Page (_, Toplevel _) -> None
  | Asset (_, Pkg pkg) -> Some pkg
  | Asset (_, Toplevel _) -> None
;;

let lib t =
  match t.kind with
  | Module (_, (Lib (_, lib) | Private_lib (_, lib))) -> Some lib
  | Impl (_, (Lib (_, lib) | Private_lib (_, lib))) -> Some lib
  | Page _ | Asset _ -> None
;;

let lib_name t =
  match t.kind with
  | Module (_, (Lib (_, lib) | Private_lib (_, lib))) -> Lib.name lib
  | Impl (_, (Lib (_, lib) | Private_lib (_, lib))) -> Lib.name lib
  | Page (_, Pkg pkg) -> Lib_name.of_string (Package.Name.to_string pkg)
  | Page (_, Toplevel _) -> Lib_name.of_string "index"
  | Asset (_, Pkg pkg) -> Lib_name.of_string (Package.Name.to_string pkg)
  | Asset (_, Toplevel _) -> Lib_name.of_string "index"
;;

let odoc_dir ctx t =
  match t.kind with
  | Module (_, target) -> Odoc_paths.odocs ctx target
  | Impl (_, target) -> Odoc_paths.odocs ctx target
  | Page (_, target) -> Odoc_paths.odocs ctx target
  | Asset (_, target) -> Odoc_paths.odocs ctx target
;;

let split_page_name name =
  match String.rsplit2 name ~on:'/' with
  | Some (parent, leaf) -> Some parent, leaf
  | None -> None, name
;;

let get_basename t =
  match t.kind, t.source with
  | Page (page, _), _ -> snd (split_page_name page.name)
  | Asset (asset, _), _ -> snd (split_page_name asset.asset_rel_path)
  | Module (_, _), Local_source src_path ->
    Path.Build.basename src_path |> Filename.remove_extension |> Filename.to_string
  | Module (mod_, _), (Installed_source _ | Generated _) ->
    Module_name.to_string mod_.module_name |> String.uncapitalize_ascii
  | Impl (impl, _), _ ->
    "impl-" ^ (Module_name.to_string impl.module_name |> String.uncapitalize_ascii)
;;

let odoc_file ctx t =
  let basename = get_basename t in
  match t.kind with
  | Page (page, target) ->
    let base_dir = Odoc_paths.odocs ctx target in
    (match fst (split_page_name page.name) with
     | Some parent_path -> base_dir ++ parent_path ++ ("page-" ^ basename ^ ".odoc")
     | None -> base_dir ++ ("page-" ^ basename ^ ".odoc"))
  | Asset (asset, target) ->
    let base_dir = Odoc_paths.odocs ctx target in
    (match fst (split_page_name asset.asset_rel_path) with
     | Some parent_path -> base_dir ++ parent_path ++ ("asset-" ^ basename ^ ".odoc")
     | None -> base_dir ++ ("asset-" ^ basename ^ ".odoc"))
  | Module (_, target) ->
    let base_dir = Odoc_paths.odocs ctx target in
    base_dir ++ (basename ^ ".odoc")
  | Impl (_, target) ->
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
  | Asset (asset, target) ->
    let base_dir = Odoc_paths.odocl ctx target in
    (match fst (split_page_name asset.asset_rel_path) with
     | Some parent_path -> base_dir ++ parent_path ++ ("asset-" ^ basename ^ ".odocl")
     | None -> base_dir ++ ("asset-" ^ basename ^ ".odocl"))
  | Module (_, target) ->
    let base_dir = Odoc_paths.odocl ctx target in
    base_dir ++ (basename ^ ".odocl")
  | Impl (_, target) ->
    let base_dir = Odoc_paths.odocl ctx target in
    base_dir ++ (basename ^ ".odocl")
;;

(* Base output directory for an artifact in the given format. Only Impl
   artifacts in Html format use a different base (the src-rendering layout);
   all other combinations use [Odoc_paths.output]. *)
let output_base ctx mode format t =
  match t.kind, (format : Odoc_paths.output_format) with
  | Impl (_, target), Html -> Odoc_paths.html_src ctx mode target
  | Module (_, target), _ -> Odoc_paths.output ctx mode format target
  | Impl (_, target), _ -> Odoc_paths.output ctx mode format target
  | Page (_, target), _ -> Odoc_paths.output ctx mode format target
  | Asset (_, target), _ -> Odoc_paths.output ctx mode format target
;;

let output_extension : Odoc_paths.output_format -> Filename.Extension.t = function
  | Html -> Filename.Extension.html
  | Json -> Filename.Extension.html_json
  | Markdown -> Filename.Extension.md
;;

let output_file ctx mode format t =
  let base = output_base ctx mode format t in
  let basename = get_basename t in
  let suffix = output_extension format in
  match t.kind, (format : Odoc_paths.output_format) with
  | Module _, (Html | Json) ->
    let dir = base ++ Stdune.String.capitalize basename in
    dir ++ ("index" ^ Filename.Extension.to_string suffix)
  | Module _, Markdown -> base ++ (Stdune.String.capitalize basename ^ Filename.Extension.to_string suffix)
  | Impl (impl, _), _ ->
    let src_basename = Path.basename impl.src_path |> Filename.to_string in
    base ++ (src_basename ^ Filename.Extension.to_string suffix)
  | Page (page, _), _ ->
    let path =
      match fst (split_page_name page.name) with
      | Some parent_path -> base ++ parent_path ++ basename
      | None -> base ++ basename
    in
    Path.Build.set_extension path ~ext:suffix
  | Asset (asset, _), (Html | Json) ->
    (match fst (split_page_name asset.asset_rel_path) with
     | Some parent_path -> base ++ parent_path ++ basename
     | None -> base ++ basename)
  | Asset _, Markdown -> base ++ basename
;;

let output_dir_target ctx mode format t =
  match t.kind, (format : Odoc_paths.output_format) with
  | Module (_, target), (Html | Json) ->
    let basename = get_basename t in
    let base = Odoc_paths.output ctx mode format target in
    Some (base ++ Stdune.String.capitalize basename)
  | Module (_, target), Markdown -> Some (Odoc_paths.output ctx mode format target)
  | Impl _, _ | Page _, _ | Asset _, _ -> None
;;

let hidden t =
  match t.kind with
  | Page _ | Asset _ | Impl _ -> false
  | Module _ ->
    let basename = get_basename t in
    String.contains_double_underscore basename
;;

let parent_id t =
  let base_id =
    match t.kind with
    | Module (_, Lib (pkg, lib)) | Impl (_, Lib (pkg, lib)) ->
      sprintf "%s/%s" (Package.Name.to_string pkg) (Lib_name.to_string (Lib.name lib))
    | Module (_, Private_lib (lib_unique_name, _))
    | Impl (_, Private_lib (lib_unique_name, _)) -> lib_unique_name
    | Page (_, Pkg pkg) -> Package.Name.to_string pkg
    | Page (_, Toplevel _) -> ""
    | Asset (_, Pkg pkg) -> Package.Name.to_string pkg
    | Asset (_, Toplevel _) -> ""
  in
  match t.kind with
  | Module _ | Impl _ -> base_id
  | Page (page, _) ->
    (match fst (split_page_name page.name) with
     | Some parent_path -> sprintf "%s/%s" base_id parent_path
     | None -> base_id)
  | Asset (asset, _) ->
    (match fst (split_page_name asset.asset_rel_path) with
     | Some parent_path -> sprintf "%s/%s" base_id parent_path
     | None -> base_id)
;;

let is_lib_vendored lib =
  let lib_info = Lib.info lib in
  match Lib_info.status lib_info with
  | Installed_private | Installed -> Memo.return false
  | Public _ | Private _ ->
    let src_path = Path.drop_optional_build_context (Lib_info.src_dir lib_info) in
    (match Path.as_in_source_tree src_path with
     | Some src_dir -> Source_tree.is_vendored src_dir
     | None -> Memo.return false)
;;

let should_suppress_output t =
  match t.source with
  | Installed_source _ -> Memo.return true
  | Generated _ -> Memo.return true
  | Local_source _ ->
    (match t.kind with
     | Module (_, (Lib (_, lib) | Private_lib (_, lib)))
     | Impl (_, (Lib (_, lib) | Private_lib (_, lib))) -> is_lib_vendored lib
     | Page _ | Asset _ -> Memo.return false)
;;

let create ~kind ~source ~extra_libs ~extra_packages =
  { kind; source; extra_libs; extra_packages }
;;

let asset_name t =
  match t.kind with
  | Asset (asset, _) -> Some asset.asset_name
  | Page _ | Module _ | Impl _ -> None
;;

let is_asset t =
  match t.kind with
  | Asset _ -> true
  | Page _ | Module _ | Impl _ -> false
;;

let is_impl t =
  match t.kind with
  | Impl _ -> true
  | Module _ | Page _ | Asset _ -> false
;;

let impl_source_path t =
  match t.kind with
  | Impl (impl, _) -> Some impl.src_path
  | Module _ | Page _ | Asset _ -> None
;;

let impl_source_id t =
  match t.kind with
  | Impl (impl, _) -> Some impl.src_id
  | Module _ | Page _ | Asset _ -> None
;;
