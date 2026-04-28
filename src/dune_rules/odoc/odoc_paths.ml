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

let lib_dir base local_lib =
  let lib = Lib.Local.to_lib local_lib in
  match Lib_info.package (Lib.info lib) with
  | Some pkg -> base ++ Package.Name.to_string pkg ++ Lib_name.to_string (Lib.name lib)
  | None -> base ++ Odoc_scope.lib_unique_name local_lib
;;

let odocs : type a. Context.t -> a Odoc_target.t -> Path.Build.t =
  fun ctx -> function
  | Odoc_target.Lib local_lib -> lib_dir (root ctx ++ "_odoc") local_lib
  | Odoc_target.Pkg pkg -> root ctx ++ "_odoc" ++ "pkg" ++ Package.Name.to_string pkg
;;

let output_root ctx format = root ctx ++ output_subdir format
let odocl_root ctx = root ctx ++ "_odocls"
let sherlodoc_root ctx = root ctx ++ "_sherlodoc"

let output : type a. Context.t -> output_format -> a Odoc_target.t -> Path.Build.t =
  fun ctx format target ->
  let base = output_root ctx format in
  match target with
  | Lib local_lib -> lib_dir base local_lib
  | Pkg pkg -> base ++ Package.Name.to_string pkg
;;

let odocl : type a. Context.t -> a Odoc_target.t -> Path.Build.t =
  fun ctx -> function
  | Lib local_lib -> lib_dir (odocl_root ctx) local_lib
  | Pkg pkg -> odocl_root ctx ++ Package.Name.to_string pkg
;;

let gen_mld_dir ctx pkg = root ctx ++ "_mlds" ++ Package.Name.to_string pkg
let odoc_support ctx = output_root ctx Html ++ odoc_support_dirname
