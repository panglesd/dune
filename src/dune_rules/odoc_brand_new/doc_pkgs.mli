open Import
module Ext_loc_map : module type of Map.Make (Dune_package.External_location)

type ext_loc_maps =
  { findlib_paths : int Path.Map.t
  ; loc_of_pkg : Dune_package.External_location.t Package.Name.Map.t
  ; loc_of_lib : Dune_package.External_location.t Lib_name.Map.t
  ; libs_of_loc : (Dune_package.Lib.t * Lib.t) Lib_name.Map.t Ext_loc_map.t
  }

val stdlib_lib : Context_name.t -> Lib.t option Memo.t

module Classify : sig
  (** Here we classify top-level dirs in the findlib paths. They are either
      packages built by dune for which we have all the info we need -
      a [Modules.t] value - or there exists one (or more!) libraries within
      the directory that don't satisfy this, and these are labelled
      fallback directories. *)

  (** The fallback is simply a map of subdirectory to list of libraries
      found in that subdir. This is the value returned by [libs_of_local_dir] *)
  type fallback = { libs : Lib.t Lib_name.Map.t }

  val fallback_equal : fallback -> fallback -> bool
  val fallback_to_dyn : fallback -> Dyn.t
  val fallback_hash : fallback -> int

  type local_dir_type =
    | Nothing
    | Dune_with_modules of (Package.Name.t * Lib.t)
    | Fallback of fallback
end

module Valid : sig
  (** These functions return a allowlist of libraries and packages that
      should be documented. There is one single function that performs this
      task because there needs to be an exact correspondence at various points
      in the process - e.g. the indexes need to know exactly which libraries will
      be documented and where. *)

  val libs_maps : Context.t -> all:bool -> ext_loc_maps Memo.t
  val get : Context.t -> all:bool -> (Lib.t list * Dune_lang.Package_name.t list) Memo.t
  val filter_libs : Context.t -> all:bool -> Lib.t list -> Lib.t list Memo.t

  val filter_fallback_libs
    :  Context.t
    -> all:bool
    -> Lib.t Lib_name.Map.t
    -> Lib.t Lib_name.Map.t Memo.t

  type categorized =
    { packages : Package.Name.Set.t
    ; local : Lib.Local.t Lib_name.Map.t
    ; externals : Classify.local_dir_type Ext_loc_map.t
    }

  val get_categorized : Context.t -> bool -> categorized Memo.t
end
