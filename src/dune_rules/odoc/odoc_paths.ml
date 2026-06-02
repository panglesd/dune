open Import
open Odoc_target

let ( ++ ) = Path.Build.relative
let odoc_support_dirname = "odoc.support"
let root (context : Context.t) = Path.Build.relative (Context.build_dir context) "_doc"

let odocs ctx = function
  | Lib lib ->
    let obj_dir = Lib.Local.obj_dir lib in
    Obj_dir.odoc_dir obj_dir
  | Pkg pkg -> root ctx ++ sprintf "_odoc/pkg/%s" (Package.Name.to_string pkg)
;;

let html_root ctx = root ctx ++ "_html"
let markdown_root ctx = root ctx ++ "_markdown"
let odocl_root ctx = root ctx ++ "_odocls"

let add_pkg_lnu base m =
  base
  ++
  match m with
  | Pkg pkg -> Package.Name.to_string pkg
  | Lib lib -> Odoc_scope.pkg_or_lnu (Lib.Local.to_lib lib)
;;

let html ctx m = add_pkg_lnu (html_root ctx) m
let markdown ctx m = add_pkg_lnu (markdown_root ctx) m
let odocl ctx m = add_pkg_lnu (odocl_root ctx) m
let gen_mld_dir ctx pkg = root ctx ++ "_mlds" ++ Package.Name.to_string pkg
let odoc_support ctx = html_root ctx ++ odoc_support_dirname
let toplevel_index ctx = html_root ctx ++ "index.html"
let markdown_index ctx = markdown_root ctx ++ "index.md"
