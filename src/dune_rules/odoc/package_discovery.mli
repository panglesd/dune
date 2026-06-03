open Import

(** Metadata about installed (external) packages, read from findlib. *)
type t

val create : context:Context.t -> t Memo.t

(** The installed libraries of a package (excluding virtual-library
    implementations), empty if the package is not installed. *)
val libraries_of_package : t -> Package.Name.t -> Lib.t list

(** The version of an installed package, if findlib records one. *)
val version_of_package : t -> Package.Name.t -> string option Memo.t
