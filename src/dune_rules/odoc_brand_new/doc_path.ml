open Import
module Gen_rules = Build_config.Gen_rules

let ( ++ ) = Path.Build.relative

module Paths = struct
  let root (context : Context.t) =
    let sub = "_doc_new" in
    Path.Build.relative (Context.build_dir context) sub
  ;;

  let html_root ctx = root ctx ++ "html"

  let odoc_support ctx =
    let odoc_support_dirname = "docs/odoc.support" in
    html_root ctx ++ odoc_support_dirname
  ;;
end
