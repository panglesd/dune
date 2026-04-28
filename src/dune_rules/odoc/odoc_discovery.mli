open Import

val get_workspace_packages : unit -> Package.Name.t list Memo.t
val libs_of_pkg : Context.t -> pkg:Package.Name.t -> Lib.t list Memo.t

val discover_package_artifacts
  :  Super_context.t
  -> Context.t
  -> pkg_or_lib_unique_name:string
  -> (Odoc_artifact.t list * string list) Memo.t

val collect_all_visible_odocls
  :  Super_context.t
  -> unit
  -> (Package.Name.t list * Path.Build.t list) Memo.t
