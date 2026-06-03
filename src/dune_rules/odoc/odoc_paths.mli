open Import

(** Output paths for the odoc rules, keyed by documentation [Odoc_target.t]. *)

type output_format =
  | Html
  | Json
  | Markdown

(** File extension produced for the given output format. *)
val extension : output_format -> string

val odoc_support_dirname : string
val root : Context.t -> Path.Build.t
val odocs : Context.t -> Odoc_target.t -> Path.Build.t

(** Path of the [.odoc] file for module [m] of local library [lib], inside the
    library's odoc directory. *)
val lib_module_odoc : Context.t -> Lib.Local.t -> Module.t -> Path.Build.t

val html_root : Context.t -> Path.Build.t
val markdown_root : Context.t -> Path.Build.t
val odocl_root : Context.t -> Path.Build.t
val html : Context.t -> Odoc_target.t -> Path.Build.t
val markdown : Context.t -> Odoc_target.t -> Path.Build.t
val odocl : Context.t -> Odoc_target.t -> Path.Build.t
val gen_mld_dir : Context.t -> Package.Name.t -> Path.Build.t
val odoc_support : Context.t -> Path.Build.t
val toplevel_index : Context.t -> Path.Build.t
val markdown_index : Context.t -> Path.Build.t
