open Import

type page = { name : string }

type mod_ =
  { visible : bool
  ; module_name : Module_name.t
  }

type _ t =
  | Lib : Lib.Local.t -> mod_ t
  | Pkg : Package.Name.t -> page t
