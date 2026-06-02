open Import

(** Scope key encoding for v2 library names.

    Private libraries from different projects need unique identifiers to avoid
    name collisions. The [Scope_key] module encodes project information into
    library names using the format "libname@key" where [key] is a 12-character
    hash derived from the project name and root path. *)
module Scope_key : sig
  (** Parse a possibly scope-encoded library name, returning the library name
      and the [Lib.DB.t] it should be looked up in. *)
  val of_string : Context_name.t -> string -> (Lib_name.t * Lib.DB.t) Memo.t

  (** Encode a private library name for the given project as "libname@key". *)
  val to_string : Lib_name.t -> Dune_project.t -> string
end

(** Unique name for a library: its plain name for public libraries, the v2
    "libname@key" format for private libraries. Raises on installed libraries. *)
val lib_unique_name : Lib.t -> string

(** Directory name for a library's documentation: its package name if it has
    one, otherwise its [lib_unique_name]. *)
val pkg_or_lnu : Lib.t -> string
