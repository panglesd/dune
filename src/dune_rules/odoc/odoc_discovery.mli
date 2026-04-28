open Import

val get_workspace_packages : unit -> Package.Name.t list Memo.t
val libs_of_pkg : Context.t -> pkg:Package.Name.t -> Lib.t list Memo.t
val toplevel_index_artifact : Context.t -> Odoc_artifact.t Memo.t

module Toplevel_index : sig
  type pkg_item =
    { name : string
    ; version : Package_version.t option
    }

  type item = Package of pkg_item

  (** Get items to display in the toplevel index. *)
  val get_items : Context.t -> item list Memo.t

  (** Generate mld content for the toplevel index. *)
  val mld_content : item list -> string
end

val discover_package_artifacts
  :  Super_context.t
  -> Context.t
  -> pkg_or_lib_unique_name:string
  -> (Odoc_artifact.t list * string list) Memo.t

val collect_all_visible_odocls
  :  Super_context.t
  -> unit
  -> (Package.Name.t list * Path.Build.t list) Memo.t
