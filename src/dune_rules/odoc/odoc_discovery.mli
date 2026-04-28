open Import

val get_workspace_packages : unit -> Package.Name.t list Memo.t
val libs_of_pkg : Context.t -> pkg:Package.Name.t -> Lib.t list Memo.t

val discover_package_artifacts
  :  Super_context.t
  -> Context.t
  -> default_index:
       (pkg:Package.Name.t -> lib_artifacts:(Lib.t * Odoc_artifact.t list) list -> string)
  -> pkg_or_lib_unique_name:string
  -> (Odoc_artifact.t list * string list) Memo.t

val collect_all_visible_odocls
  :  Super_context.t
  -> default_index:
       (pkg:Package.Name.t -> lib_artifacts:(Lib.t * Odoc_artifact.t list) list -> string)
  -> unit
  -> (Package.Name.t list * Path.Build.t list) Memo.t
