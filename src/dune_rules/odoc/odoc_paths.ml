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

(* External (installed) libraries are not part of any scope, so their odoc
   tree is keyed by their plain library name. *)
let ext_lib_name lib = Lib_name.to_string (Lib.name lib)

let odocs ctx = function
  | Lib lib -> odoc_root ctx ++ Odoc_scope.lib_unique_name (Lib.Local.to_lib lib)
  | Ext_lib lib -> odoc_root ctx ++ ext_lib_name lib
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
  | Ext_lib lib -> ext_lib_name lib
;;

let json ctx ~mode = function
  | Pkg pkg -> json_root ctx ~mode ++ Package.Name.to_string pkg
  | Lib lib -> json_root ctx ~mode ++ Odoc_scope.lib_unique_name (Lib.Local.to_lib lib)
  | Ext_lib lib -> json_root ctx ~mode ++ ext_lib_name lib
;;

let html ctx ~mode = function
  | Pkg pkg -> html_root ctx ~mode ++ Package.Name.to_string pkg
  | Lib lib -> html_root ctx ~mode ++ Odoc_scope.lib_unique_name (Lib.Local.to_lib lib)
  | Ext_lib lib -> html_root ctx ~mode ++ ext_lib_name lib
;;

let markdown ctx m = add_pkg_lnu (markdown_root ctx) m

let odocl ctx = function
  | Pkg pkg -> odocl_root ctx ++ Package.Name.to_string pkg
  | Lib lib -> odocl_root ctx ++ Odoc_scope.lib_unique_name (Lib.Local.to_lib lib)
  | Ext_lib lib -> odocl_root ctx ++ ext_lib_name lib
;;

let classify_root ctx = root ctx ++ "_classify"

(* [odoc classify] output for an external library, keyed by library name. *)
let classify_file ctx lib = classify_root ctx ++ ext_lib_name lib ++ "odoc.classify"
let gen_mld_dir ctx pkg = root ctx ++ "_mlds" ++ Package.Name.to_string pkg
let odoc_support ctx ~mode = html_root ctx ~mode ++ odoc_support_dirname
let toplevel_index ctx ~mode = html_root ctx ~mode ++ "index.html"
let json_index ctx ~mode = json_root ctx ~mode ++ "index.html.json"
let markdown_index ctx = markdown_root ctx ++ "index.md"
