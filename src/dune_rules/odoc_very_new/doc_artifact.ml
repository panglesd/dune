open Import
open Doc_index

let ( ++ ) = Path.Build.relative

(* An artifact is a single compilation unit (module) or mld file, and contains
   all info to find the html output, the odoc file, the source, whether it's
   hidden or not, to construct a reference to it, to find the index under
   which it's found, and so on. *)

type artifact_ty =
  | Module of bool
  | Mld

type t =
  { source : Path.t
  ; name : string
  ; html_dir : Path.Build.t
  ; html_file : Path.Build.t
  ; ty : artifact_ty
  ; parent_id : Odoc_parent_id.t
  }

let odoc_file ctx v =
  let prefix =
    match v.ty with
    | Module _ -> ""
    | Mld -> "page-"
  in
  let filename = prefix ^ v.name ^ ".odoc" in
  Odoc_parent_id.to_path ~root:(Index.odoc_root ctx) v.parent_id ++ filename
;;

let odocl_file ctx v =
  let odocf = odoc_file ctx v in
  Path.Build.set_extension odocf ~ext:".odocl"
;;

let source_file v = v.source
let html_file v = v.html_file
let html_dir v = v.html_dir
let odoc_parent_id v = v.parent_id

let is_visible v =
  match v.ty with
  | Module x -> x
  | Mld -> true
;;

let is_module v =
  match v.ty with
  | Module _ -> true
  | Mld -> false
;;

let artifact_ty v = v.ty

let reference v =
  match v.ty with
  | Mld ->
    let basename = Path.basename v.source |> Filename.remove_extension in
    sprintf "page-\"%s\"" basename
  | Module _ ->
    let basename =
      Path.basename v.source |> Filename.remove_extension |> Stdune.String.capitalize
    in
    sprintf "module-%s" basename
;;

let module_name v =
  match v.ty with
  | Module _ ->
    let basename =
      Path.basename v.source |> Filename.remove_extension |> Stdune.String.capitalize
    in
    Some (Module_name.of_string_allow_invalid (Loc.none, basename))
  | _ -> None
;;

let name v = Path.basename v.source |> Filename.remove_extension

let v ~source ~html_dir ~html_file ~ty ~parent_id ~name =
  { source; html_dir; html_file; ty; parent_id; name }
;;

let make_module ctx index source ~visible =
  let basename =
    Path.basename source |> Filename.remove_extension |> Stdune.String.uncapitalize
  in
  let parent_id = Index.parent_id index in
  let html_dir = Index.html_dir ctx index ++ Stdune.String.capitalize basename in
  let html = html_dir ++ "index.html" in
  (* Note: odoc will not create any output for modules that it believes are
     hidden - which entirely depends upon whether there is a double underscore
     in the name. So we declare anything with a double underscore as hidden
     in addition to anything that dune believes should not be an entry module. *)
  let visible = visible && not (String.contains_double_underscore basename) in
  v ~source ~html_dir ~html_file:html ~ty:(Module visible) ~parent_id ~name:basename
;;

let int_make_mld ctx index source ~is_index:_ =
  let basename = Path.basename source |> Filename.remove_extension in
  (* TODO : check [page-] is not there *)
  let parent_id = Index.parent_id index in
  let html_dir = Index.html_dir ctx index in
  let html = html_dir ++ sprintf "%s.html" basename in
  v ~source ~html_dir ~html_file:html ~ty:Mld ~parent_id ~name:basename
;;

let external_mld ctx index source = int_make_mld ctx index source ~is_index:false

let index ctx index =
  let source =
    let filename = Index.mld_filename index in
    let dir = Index.obj_dir ctx index in
    Path.build (dir ++ filename)
  in
  int_make_mld ctx index source ~is_index:true
;;
