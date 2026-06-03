open Import

(** Discovery of the documentation artifacts (libraries, modules, mlds, ...)
    that the odoc rules operate on. *)

(** Local libraries of a package, excluding implementations of virtual
    libraries. *)
val libs_of_pkg : Context_name.t -> pkg:Package.Name.t -> Lib.Local.t list Memo.t
