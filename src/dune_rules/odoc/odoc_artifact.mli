open Import

(** A single odoc artifact: the [.odoc] file together with its documentation
    target, from which the [.odocl] and output paths are derived. *)
type t

val make : target:Odoc_target.t -> Path.Build.t -> t
val odoc_file : t -> Path.Build.t

(** Whether this artifact is a module (vs a package mld page). A module's html
    output is a directory tree; an mld's is a single file. *)
val is_module : t -> bool

val odocl_file : Context.t -> t -> Path.Build.t
val output_file : Context.t -> Odoc_paths.output_format -> t -> Path.Build.t
