open Import

let ( ++ ) = Path.Build.relative

type output_format =
  | Html
  | Json
  | Markdown

let output_subdir = function
  | Html | Json -> "_html"
  | Markdown -> "_markdown"
;;

let odoc_support_dirname = "odoc.support"
let root (context : Context.t) = Path.Build.relative (Context.build_dir context) "_doc"

let pkg_or_lnu local_lib =
  let lib = Lib.Local.to_lib local_lib in
  match Lib_info.package (Lib.info lib) with
  | Some pkg -> Package.Name.to_string pkg
  | None -> Odoc_scope.lib_unique_name local_lib
;;

let add_pkg_lnu : type a. Path.Build.t -> a Odoc_target.t -> Path.Build.t =
  fun base -> function
  | Odoc_target.Lib local_lib -> base ++ pkg_or_lnu local_lib
  | Odoc_target.Pkg pkg -> base ++ Package.Name.to_string pkg
;;

let odocs : type a. Context.t -> a Odoc_target.t -> Path.Build.t =
  fun ctx -> function
  | Odoc_target.Lib local_lib -> Obj_dir.odoc_dir (Lib.Local.obj_dir local_lib)
  | Odoc_target.Pkg pkg -> root ctx ++ "_odoc" ++ "pkg" ++ Package.Name.to_string pkg
;;

let output_root ctx format = root ctx ++ output_subdir format
let odocl_root ctx = root ctx ++ "_odocls"
let output ctx format target = add_pkg_lnu (output_root ctx format) target
let odocl ctx target = add_pkg_lnu (odocl_root ctx) target
let gen_mld_dir ctx pkg = root ctx ++ "_mlds" ++ Package.Name.to_string pkg
let odoc_support ctx = output_root ctx Html ++ odoc_support_dirname
