open Import

type output_format =
  | Html
  | Json
  | Markdown

val root : Context.t -> Path.Build.t
val odocs : Context.t -> 'a Odoc_target.t -> Path.Build.t
val output_root : Context.t -> output_format -> Path.Build.t
val output : Context.t -> output_format -> 'a Odoc_target.t -> Path.Build.t
val odocl_root : Context.t -> Path.Build.t
val sherlodoc_root : Context.t -> Path.Build.t
val odocl : Context.t -> 'a Odoc_target.t -> Path.Build.t
val gen_mld_dir : Context.t -> Package.Name.t -> Path.Build.t
val lib_index_mld : Context.t -> Package.Name.t -> Lib_name.t -> Path.Build.t
val odoc_support : Context.t -> Path.Build.t

(** Path to toplevel index.mld (generated). *)
val toplevel_index_mld : Context.t -> Path.Build.t

(** Path to the remap.txt file for URL remapping. *)
val remap_file : Context.t -> Path.Build.t
