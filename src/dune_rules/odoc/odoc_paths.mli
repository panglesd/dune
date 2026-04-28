open Import
module Doc_mode = Odoc_target.Doc_mode

type output_format =
  | Html
  | Json
  | Markdown

type sidebar_scope =
  | Per_package of Package.Name.t
  | Global

val root : Context.t -> Path.Build.t
val odocs : Context.t -> 'a Odoc_target.t -> Path.Build.t
val output_root : Context.t -> Doc_mode.t -> output_format -> Path.Build.t
val output : Context.t -> Doc_mode.t -> output_format -> 'a Odoc_target.t -> Path.Build.t
val odocl_root : Context.t -> Path.Build.t
val sherlodoc_root : Context.t -> Path.Build.t
val odocl : Context.t -> 'a Odoc_target.t -> Path.Build.t
val gen_mld_dir : Context.t -> Package.Name.t -> Path.Build.t
val lib_index_mld : Context.t -> Package.Name.t -> Lib_name.t -> Path.Build.t
val odoc_support : Context.t -> Doc_mode.t -> Path.Build.t

(** Path to odoc support files within a package directory (for per-package mode). *)
val odoc_support_for_pkg : Context.t -> Doc_mode.t -> string -> Path.Build.t

(** Path to toplevel index.mld (generated). *)
val toplevel_index_mld : Context.t -> Doc_mode.t -> Path.Build.t

(** Path to sidebar index file (.odoc-index). *)
val index_file : Context.t -> Doc_mode.t -> sidebar_scope -> Path.Build.t

(** Path to binary sidebar file (.odoc-sidebar). *)
val sidebar_file : Context.t -> Doc_mode.t -> sidebar_scope -> Path.Build.t

(** Path to sidebar.json for web-based navigation. *)
val sidebar_json
  :  Context.t
  -> Doc_mode.t
  -> sidebar_scope
  -> output_format
  -> Path.Build.t

(** Path to the remap.txt file for Local_only mode URL remapping. *)
val remap_file : Context.t -> Path.Build.t
