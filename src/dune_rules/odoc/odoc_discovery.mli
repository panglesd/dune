open Import

val discover_local_lib_artifacts
  :  Super_context.t
  -> local_lib:Lib.Local.t
  -> Odoc_artifact.t list Memo.t

val discover_package_artifacts
  :  Super_context.t
  -> Context.t
  -> default_index:
       (pkg:Package.Name.t -> lib_artifacts:(Lib.t * Odoc_artifact.t list) list -> string)
  -> pkg_or_lib_unique_name:string
  -> (Odoc_artifact.t list
     * string list
     * (Path.Build.t * string) option
     * Package.Name.t option)
       Memo.t
