open Import

let ( ++ ) = Path.Build.relative

type output_format =
  | Html
  | Json
  | Markdown

let output_subdir = function
  | Html -> "_html"
  | Json -> "_json"
  | Markdown -> "_markdown"
;;

let odoc_support_dirname = "odoc.support"
let root (context : Context.t) = Path.Build.relative (Context.build_dir context) "_doc"
let index_root ctx = root ctx ++ "_index"

let odocs : type a. Context.t -> a Odoc_target.t -> Path.Build.t =
  fun ctx -> function
  | Odoc_target.Lib (pkg, lib) ->
    let lib_name = Lib.name lib in
    root ctx ++ "_odoc" ++ Package.Name.to_string pkg ++ Lib_name.to_string lib_name
  | Odoc_target.Private_lib (lib_unique_name, _) -> root ctx ++ "_odoc" ++ lib_unique_name
  | Odoc_target.Pkg pkg -> root ctx ++ "_odoc" ++ Package.Name.to_string pkg
  | Odoc_target.Toplevel -> index_root ctx
;;

let output_root ctx format = root ctx ++ output_subdir format
let odocl_root ctx = root ctx ++ "_odocls"
let sherlodoc_root ctx = root ctx ++ "_sherlodoc"

let output : type a. Context.t -> output_format -> a Odoc_target.t -> Path.Build.t =
  fun ctx format target ->
  let base = output_root ctx format in
  match target with
  | Lib (pkg, lib) ->
    let lib_name = Lib.name lib in
    base ++ Package.Name.to_string pkg ++ Lib_name.to_string lib_name
  | Private_lib (lib_unique_name, _) -> base ++ lib_unique_name
  | Pkg pkg -> base ++ Package.Name.to_string pkg
  | Toplevel -> base
;;

let odocl : type a. Context.t -> a Odoc_target.t -> Path.Build.t =
  fun ctx -> function
  | Lib (pkg, lib) ->
    let lib_name = Lib.name lib in
    odocl_root ctx ++ Package.Name.to_string pkg ++ Lib_name.to_string lib_name
  | Private_lib (lib_unique_name, _) -> odocl_root ctx ++ lib_unique_name
  | Pkg pkg -> odocl_root ctx ++ Package.Name.to_string pkg
  | Toplevel -> index_root ctx
;;

let gen_mld_dir ctx pkg = root ctx ++ "_mlds" ++ Package.Name.to_string pkg
let lib_mld_dir ctx pkg lib_name = gen_mld_dir ctx pkg ++ Lib_name.to_string lib_name
let lib_index_mld ctx pkg lib_name = lib_mld_dir ctx pkg lib_name ++ "index.mld"
let odoc_support ctx = output_root ctx Html ++ odoc_support_dirname
let toplevel_index_mld ctx = index_root ctx ++ "index.mld"
