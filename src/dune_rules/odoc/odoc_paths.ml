open Import
open Odoc_target

let ( ++ ) = Path.Build.relative

type output_format =
  | Html
  | Json
  | Markdown

let extension = function
  | Html -> ".html"
  | Json -> ".html.json"
  | Markdown -> ".md"
;;

let odoc_support_dirname = "odoc.support"
let root (context : Context.t) = Path.Build.relative (Context.build_dir context) "_doc"
let odoc_root ctx = root ctx ++ "_odoc"

let odocs ctx = function
  | Lib lib -> odoc_root ctx ++ Odoc_scope.lib_unique_name (Lib.Local.to_lib lib)
  | Pkg pkg -> odoc_root ctx ++ Package.Name.to_string pkg
;;

let lib_module_odoc ctx lib m =
  let basename =
    Module_name.Unique.artifact_filename (Module.obj_name m) ~ext:Filename.Extension.odoc
  in
  odocs ctx (Lib lib) ++ basename
;;

let html_root ctx ~(mode : Odoc_mode.t) =
  root ctx
  ++
  match mode with
  | Local_only -> "_html"
  | Full -> "_html_full"
;;

let json_root ctx ~(mode : Odoc_mode.t) =
  root ctx
  ++
  match mode with
  | Local_only -> "_json"
  | Full -> "_json_full"
;;

let markdown_root ctx = root ctx ++ "_markdown"
let odocl_root ctx = root ctx ++ "_odocls"

let add_pkg_lnu base m =
  base
  ++
  match m with
  | Pkg pkg -> Package.Name.to_string pkg
  | Lib lib -> Odoc_scope.pkg_or_lnu (Lib.Local.to_lib lib)
;;

let json ctx ~mode = function
  | Pkg pkg -> json_root ctx ~mode ++ Package.Name.to_string pkg
  | Lib lib -> json_root ctx ~mode ++ Odoc_scope.lib_unique_name (Lib.Local.to_lib lib)
;;

let html ctx ~mode = function
  | Pkg pkg -> html_root ctx ~mode ++ Package.Name.to_string pkg
  | Lib lib -> html_root ctx ~mode ++ Odoc_scope.lib_unique_name (Lib.Local.to_lib lib)
;;

let markdown ctx m = add_pkg_lnu (markdown_root ctx) m

let odocl ctx = function
  | Pkg pkg -> odocl_root ctx ++ Package.Name.to_string pkg
  | Lib lib -> odocl_root ctx ++ Odoc_scope.lib_unique_name (Lib.Local.to_lib lib)
;;

let gen_mld_dir ctx pkg = root ctx ++ "_mlds" ++ Package.Name.to_string pkg
let odoc_support ctx ~mode = html_root ctx ~mode ++ odoc_support_dirname
let toplevel_index ctx ~mode = html_root ctx ~mode ++ "index.html"
let json_index ctx ~mode = json_root ctx ~mode ++ "index.html.json"
let markdown_index ctx = markdown_root ctx ++ "index.md"
