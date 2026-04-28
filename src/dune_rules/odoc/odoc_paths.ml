open Import

let ( ++ ) = Path.Build.relative

module Doc_mode = Odoc_target.Doc_mode

(* Output formats are a closed variant; the helpers below centralise the
   per-format subdir/extension/layout so callers don't pattern-match. *)
type output_format =
  | Html
  | Json
  | Markdown

let output_subdir format mode =
  match format, mode with
  | Html, Doc_mode.Local_only -> "_html"
  | Html, Doc_mode.Full -> "_html_full"
  | Json, Doc_mode.Local_only -> "_json"
  | Json, Doc_mode.Full -> "_json_full"
  | Markdown, Doc_mode.Local_only -> "_markdown"
  | Markdown, Doc_mode.Full -> "_markdown_full"
;;

let odoc_support_dirname = "odoc.support"
let root (context : Context.t) = Path.Build.relative (Context.build_dir context) "_doc"

let index_root ctx mode =
  let subdir =
    match mode with
    | Doc_mode.Local_only -> "_index"
    | Doc_mode.Full -> "_index_full"
  in
  root ctx ++ subdir
;;

let odocs : type a. Context.t -> a Odoc_target.t -> Path.Build.t =
  fun ctx -> function
  | Odoc_target.Lib (pkg, lib) ->
    let lib_name = Lib.name lib in
    root ctx ++ "_odoc" ++ Package.Name.to_string pkg ++ Lib_name.to_string lib_name
  | Odoc_target.Private_lib (lib_unique_name, _) -> root ctx ++ "_odoc" ++ lib_unique_name
  | Odoc_target.Pkg pkg -> root ctx ++ "_odoc" ++ Package.Name.to_string pkg
  | Odoc_target.Toplevel mode -> index_root ctx mode
;;

let output_root ctx mode format = root ctx ++ output_subdir format mode
let odocl_root ctx = root ctx ++ "_odocls"
let sherlodoc_root ctx = root ctx ++ "_sherlodoc"

let output
  : type a. Context.t -> Doc_mode.t -> output_format -> a Odoc_target.t -> Path.Build.t
  =
  fun ctx mode format target ->
  let base = output_root ctx mode format in
  match target with
  | Lib (pkg, lib) ->
    let lib_name = Lib.name lib in
    base ++ Package.Name.to_string pkg ++ Lib_name.to_string lib_name
  | Private_lib (lib_unique_name, _) -> base ++ lib_unique_name
  | Pkg pkg -> base ++ Package.Name.to_string pkg
  | Toplevel _ -> base
;;

let odocl : type a. Context.t -> a Odoc_target.t -> Path.Build.t =
  fun ctx -> function
  | Lib (pkg, lib) ->
    let lib_name = Lib.name lib in
    odocl_root ctx ++ Package.Name.to_string pkg ++ Lib_name.to_string lib_name
  | Private_lib (lib_unique_name, _) -> odocl_root ctx ++ lib_unique_name
  | Pkg pkg -> odocl_root ctx ++ Package.Name.to_string pkg
  | Toplevel mode -> index_root ctx mode
;;

let gen_mld_dir ctx pkg = root ctx ++ "_mlds" ++ Package.Name.to_string pkg
let lib_mld_dir ctx pkg lib_name = gen_mld_dir ctx pkg ++ Lib_name.to_string lib_name
let lib_index_mld ctx pkg lib_name = lib_mld_dir ctx pkg lib_name ++ "index.mld"
let odoc_support ctx mode = output_root ctx mode Html ++ odoc_support_dirname

let odoc_support_for_pkg ctx mode pkg =
  output_root ctx mode Html ++ pkg ++ odoc_support_dirname
;;

let toplevel_index_mld ctx mode = index_root ctx mode ++ "index.mld"
let remap_file ctx = root ctx ++ "_remap" ++ "remap.txt"
