open Import

(** Discovery of the documentation artifacts (libraries, modules, mlds, ...)
    that the odoc rules operate on. *)

(** Local libraries of a package, excluding implementations of virtual
    libraries. *)
val libs_of_pkg : Context_name.t -> pkg:Package.Name.t -> Lib.Local.t list Memo.t

(** Entry modules of a local library. *)
val entry_modules_by_lib : Super_context.t -> Lib.Local.t -> Module.t list Memo.t

(** Entry modules of every public library of a package. *)
val entry_modules
  :  Super_context.t
  -> pkg:Package.Name.t
  -> Module.t list Lib.Local.Map.t Memo.t
