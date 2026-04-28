open Import

val module_artifact : local_lib:Lib.Local.t -> Module.t -> Odoc_artifact.t

val discover_local_lib_artifacts
  :  Super_context.t
  -> local_lib:Lib.Local.t
  -> Odoc_artifact.t list Memo.t

val discover_package_artifacts
  :  Super_context.t
  -> Context.t
  -> pkg_or_lib_unique_name:string
  -> (Odoc_artifact.t list
     * string list
     * (Path.Build.t * (Lib.t * Odoc_artifact.t list) list) option
     * Package.Name.t option)
       Memo.t
