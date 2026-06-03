open Import

(** A documentation target: a local library, an external (installed) library,
    or a package. *)
type t =
  | Lib of Lib.Local.t
  | Ext_lib of Lib.t
  | Pkg of Package.Name.t
