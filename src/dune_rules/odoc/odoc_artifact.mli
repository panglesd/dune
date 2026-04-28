open Import

type kind =
  | Module : Odoc_target.mod_ * Odoc_target.mod_ Odoc_target.t -> kind
  | Page : Odoc_target.page * Odoc_target.page Odoc_target.t -> kind

type source = Local_source of Path.Build.t
type t

val get_kind : t -> kind
val source_file : t -> Path.t
val odoc_file : Context.t -> t -> Path.Build.t
val odocl_file : Context.t -> t -> Path.Build.t
val odoc_dir : Context.t -> t -> Path.Build.t
val output_file : Context.t -> Odoc_paths.output_format -> t -> Path.Build.t
val pkg : t -> Package.Name.t option
val lib_name : t -> Lib_name.t
val lib : t -> Lib.t option
val hidden : t -> bool
val parent_id : t -> string
val create : kind:kind -> source:source -> t
