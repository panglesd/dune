open Import

(** A documentation target: either a local library or a package. *)
type t =
  | Lib of Lib.Local.t
  | Pkg of Package.Name.t
