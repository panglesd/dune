open Import
module Ext_loc_map : Map.S with type key = Dune_package.External_location.t

type t

val create : context:Context.t -> t Memo.t
val package_of_library : t -> Lib.t -> Package.Name.t option
val libraries_of_package : t -> Package.Name.t -> Lib.t list
val mlds_of_package : t -> Package.Name.t -> (Path.t * string) list
val assets_of_package : t -> Package.Name.t -> Path.t list
val module_source_file : t -> lib:Lib.t -> module_name:string -> Path.t option
val module_cmt_file : t -> lib:Lib.t -> module_name:string -> Path.t option
val module_ml_file : t -> lib:Lib.t -> module_name:string -> Path.t option
val config_of_package : t -> Package.Name.t -> Odoc_config.t
val version_of_package : t -> Package.Name.t -> string option Memo.t
val all_installed_packages : t -> Package.Name.t list
val findlib_paths : t -> int Path.Map.t
val location_of_package : t -> Package.Name.t -> Dune_package.External_location.t option
val location_of_library : t -> Lib_name.t -> Dune_package.External_location.t option
val libs_of_location : t -> (Dune_package.Lib.t * Lib.t) Lib_name.Map.t Ext_loc_map.t
