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

(** Check there are no two mld files with the same basename in a package. *)
val check_mlds_no_dupes
  :  pkg:Package.Name.t
  -> mlds:(Path.Build.t * string) list
  -> (Path.Build.t * string) String.Map.t

(** Warn about documentation inputs dune cannot yet build (assets, nested mlds). *)
val report_warnings : Doc_sources.mld list -> unit

(** The package mlds, split into flat .mld files (path, name) and the rest. *)
val mlds
  :  Super_context.t
  -> Package.Name.t
  -> ((Path.Build.t * string) list * Doc_sources.mld list) Memo.t
