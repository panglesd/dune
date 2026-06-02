open Import

(** A single odoc artifact: the [.odoc] file together with its documentation
    target, from which the [.odocl] and output paths are derived. *)
type t

val make : target:Odoc_target.t -> Path.Build.t -> t
val odoc_file : t -> Path.Build.t
val odocl_file : Context.t -> t -> Path.Build.t
val output_file : Context.t -> Odoc_paths.output_format -> t -> Path.Build.t
