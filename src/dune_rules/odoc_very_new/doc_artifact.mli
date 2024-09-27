(** An artifact is a single compilation unit (module) or mld file, and contains
    all info to find the html output, the odoc file, the source, whether it's
    hidden or not, to construct a reference to it, to find the index under
    which it's found, and so on. *)

open Import
open Doc_index

type artifact_ty =
  | Module of bool
  | Mld

type t

val odoc_file : Context.t -> t -> Path.Build.t
val odoc_parent_id : t -> Odoc_parent_id.t
val odocl_file : Context.t -> t -> Path.Build.t
val html_file : t -> Path.Build.t
val html_dir : t -> Path.Build.t
val source_file : t -> Path.t
val is_visible : t -> bool
val is_module : t -> bool
val artifact_ty : t -> artifact_ty
val reference : t -> string
val module_name : t -> Module_name.t option
val name : t -> string
val make_module : Context.t -> Index.t -> Path.t -> visible:bool -> t
val external_mld : Context.t -> Index.t -> Path.t -> t
val index : Context.t -> Index.t -> t
