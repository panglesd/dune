open Import

(** Discovery of the documentation artifacts (libraries, modules, mlds, ...)
    that the odoc rules operate on. *)

(** Local libraries of a package, excluding implementations of virtual
    libraries. *)
val libs_of_pkg : Context_name.t -> pkg:Package.Name.t -> Lib.Local.t list Memo.t

(** All local libraries in the workspace (across all projects), excluding
    implementations of virtual libraries. *)
val all_local_libs : Super_context.t -> Lib.Local.t list Memo.t

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

(** A documentation .mld page (its source and its name in the doc hierarchy). *)
module Mld : sig
  type t

  val create : path:Path.Build.t -> name:string -> t
  val odoc_file : doc_dir:Path.Build.t -> t -> Path.Build.t
  val odoc_input : t -> Path.Build.t
end

(** The odoc artifacts (modules or mld pages) of a documentation target. *)
val odoc_artefacts : Super_context.t -> Odoc_target.t -> Odoc_artifact.t list Memo.t

(** The toplevel package-listing index page. *)
module Toplevel_index : sig
  type item

  val of_packages : Package.t Package.Name.Map.t -> Odoc_paths.output_format -> item list
  val content : Odoc_paths.output_format -> item list -> string
end

(** Auto-generated mld content for a package's default index page. *)
val default_index : pkg:Package.Name.t -> Module.t list Lib.Local.Map.t -> string
