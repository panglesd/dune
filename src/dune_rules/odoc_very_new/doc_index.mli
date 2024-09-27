module Odoc_parent_id : sig
  type t

  val to_string : t -> string
  val v : string list -> t
  val to_path : root:Stdune.Path.Build.t -> t -> Stdune.Path.Build.t
end

module Index : sig
  type ext_ty =
    | Relative_to_stdlib
    | Relative_to_findlib of (int * Stdune.Path.t)
    | Local_packages
    | Other

  type ty =
    | Private_lib of string
    | Top_dir of ext_ty
    | Sub_dir of string

  val compare_ty : ty -> ty -> Ordering.t

  type t = ty list

  val odoc_root : Context.t -> Stdune.Path.Build.t
  val of_pkg : Doc_pkgs.ext_loc_maps -> Dune_lang.Package_name.t -> t
  val of_external_lib : Doc_pkgs.ext_loc_maps -> Lib.t -> t
  val of_local_lib : Lib.Local.t -> t
  val of_local_package : Dune_lang.Package_name.t -> t

  val of_external_loc
    :  Doc_pkgs.ext_loc_maps
    -> Dune_package.External_location.t
    -> t option

  val odoc_dir : Context.t -> t -> Stdune.Path.Build.t
  val html_dir : Context.t -> t -> Stdune.Path.Build.t
  val obj_dir : Context.t -> t -> Stdune.Path.Build.t
  val mld_filename : t -> string
  val mld_name : t -> string
  val mld_name_ty : ty -> string
  val mld_path : Context.t -> t -> Stdune.Path.Build.t
  val is_external : t -> bool
  val parent_id : t -> Odoc_parent_id.t
  val to_dyn : t -> Dyn.t
end
