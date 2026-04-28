open Import
module Ext_loc_map : Map.S with type key = Dune_package.External_location.t

type t

val create : context:Context.t -> t Memo.t
val mlds_of_package : t -> Package.Name.t -> (Path.t * string) list
val findlib_paths : t -> int Path.Map.t
val location_of_package : t -> Package.Name.t -> Dune_package.External_location.t option
val location_of_library : t -> Lib_name.t -> Dune_package.External_location.t option
val libs_of_location : t -> (Dune_package.Lib.t * Lib.t) Lib_name.Map.t Ext_loc_map.t
