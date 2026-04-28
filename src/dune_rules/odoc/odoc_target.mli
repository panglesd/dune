open Import

type page =
  { name : string
  ; pkg_libs : Lib.t list
  }

type mod_ =
  { visible : bool
  ; module_name : Module_name.t
  }

type _ t =
  | Lib : Package.Name.t * Lib.t -> mod_ t
  | Private_lib : string * Lib.t -> mod_ t
  | Pkg : Package.Name.t -> page t
  | Toplevel : page t

(** Existential wrapper for targets of any kind. *)
type any = Any : 'a t -> any

(** Compare two targets for sorting. Orders by target type then by name. *)
val compare_any : any -> any -> Ordering.t
