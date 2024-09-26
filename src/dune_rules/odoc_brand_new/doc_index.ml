open Import
open Doc_pkgs
open Doc_path

let ( ++ ) = Path.Build.relative

module Odoc_parent_id : sig
  type t

  val to_string : t -> string
  val v : string list -> t
  val to_path : root:Path.Build.t -> t -> Path.Build.t
end = struct
  (** Id ["a/b/c"] is represented as [["c" ; "b" ; "a"]] *)
  type t = string list

  let v l = List.rev l
  let to_string x = x |> List.rev |> String.concat ~sep:"/"
  let to_path ~root x = List.fold_right ~f:(Fun.flip ( ++ )) ~init:root x
end

module Index : sig
  type ext_ty =
    | Relative_to_stdlib
    | Relative_to_findlib of (int * Path.t)
    | Local_packages
    | Other (* plan b *)

  type ty =
    | Private_lib of string
    | Top_dir of ext_ty
    | Sub_dir of string

  val compare_ty : ty -> ty -> ordering

  type t = ty list

  val odoc_root : Context.t -> Path.Build.t

  (** {1 Ways to create an index} *)

  val of_pkg : ext_loc_maps -> Dune_lang.Package_name.t -> t
  val of_external_lib : ext_loc_maps -> Lib.t -> t
  val of_local_lib : Lib.Local.t -> t
  val of_local_package : Dune_lang.Package_name.t -> t
  val of_external_loc : ext_loc_maps -> Ext_loc_map.key -> t option

  (** {1 Accessing properties} *)

  val odoc_dir : Context.t -> t -> Path.Build.t
  val html_dir : Context.t -> t -> Path.Build.t
  val obj_dir : Context.t -> t -> Path.Build.t
  val mld_filename : t -> string
  val mld_name : t -> string
  val mld_name_ty : ty -> string
  val mld_path : Context.t -> t -> Path.Build.t
  val is_external : t -> bool
  val parent_id : t -> Odoc_parent_id.t

  (** {1 Dynamic respresentation} *)

  val to_dyn : t -> Dyn.t
end = struct
  (* The index represents the position in the output HTML where the
     an artifact will be found. *)

  (* Packages are found in various places on the system*)
  type ext_ty =
    | Relative_to_stdlib
    | Relative_to_findlib of (int * Path.t)
    | Local_packages
    | Other (* plan b *)

  (* The directories immediately below 'docs' represent the various
     locations of packages, and also private libraries. Underneath
     the package locations are directories that map one-to-one with
     those in the filesystem, and within these there are subdirectories
     for sublibraries. For packages installed with dune the directories
     will have the same name as the package, but for packages installed
     with other build/packaging systems we fall back to simply replicating
     the filesystem structure, which in many cases is the package name,
     but not necessarily. *)

  type ty =
    | Private_lib of string
    | Top_dir of ext_ty
    | Sub_dir of string

  type t = ty list

  (* Used to suppress warnings on packages from the switch *)
  let rec is_external = function
    | [] -> false
    | Private_lib _ :: _ -> false
    | Top_dir (Relative_to_findlib _) :: _ -> true
    | Top_dir Relative_to_stdlib :: _ -> true
    | Top_dir Local_packages :: _ -> false
    | Top_dir Other :: _ -> true
    | Sub_dir _ :: xs -> is_external xs
  ;;

  let external_ty_to_dyn x =
    let open Dyn in
    match x with
    | Local_packages -> variant "Local_packages" []
    | Relative_to_stdlib -> variant "Relative_to_stdlib" []
    | Relative_to_findlib (x, _) -> variant "Relative_to_findlib" [ Int x ]
    | Other -> variant "Other" []
  ;;

  let ty_to_dyn x =
    let open Dyn in
    match x with
    | Private_lib lnu -> variant "Private_lib" [ String lnu ]
    | Top_dir e -> variant "Package" [ external_ty_to_dyn e ]
    | Sub_dir str -> variant "LocalSubLib" [ String str ]
  ;;

  let to_dyn x = Dyn.list ty_to_dyn x
  let compare_ty x y = Dyn.compare (ty_to_dyn x) (ty_to_dyn y)

  let subdir = function
    | Private_lib s -> s
    | Top_dir Local_packages -> "local"
    | Top_dir Relative_to_stdlib -> "stdlib"
    | Top_dir (Relative_to_findlib (n, _)) -> "findlib-" ^ string_of_int n
    | Top_dir Other -> "other"
    | Sub_dir str -> str
  ;;

  let parent_id i = i |> List.rev_map ~f:subdir |> Odoc_parent_id.v
  let odoc_root ctx = Paths.root ctx ++ "odoc"

  (* Where we find the odoc files for the indexes *)
  let obj_dir ctx : t -> Path.Build.t =
    List.fold_right ~f:(fun x acc -> acc ++ subdir x) ~init:(odoc_root ctx)
  ;;

  (* Where we find the output HTML files for artifacts that are children of
     this index *)
  let html_dir ctx (m : t) =
    let init = Paths.html_root ctx in
    List.fold_right ~f:(fun x acc -> acc ++ subdir x) ~init m
  ;;

  (* Where we find odoc files for artifacts that are children of this index. *)
  let odoc_dir ctx (m : t) =
    let init = odoc_root ctx in
    List.fold_right ~f:(fun x acc -> acc ++ subdir x) ~init m
  ;;

  let mld_name_ty : ty -> string = subdir

  let mld_name : t -> string = function
    | [] -> "docs"
    | x :: _ -> mld_name_ty x
  ;;

  let mld_filename index =
    let _ = odoc_dir in
    mld_name index ^ ".mld"
  ;;

  let mld_path ctx index = obj_dir ctx index ++ mld_filename index

  let of_local_lib lib =
    match
      let info = Lib.Local.info lib in
      Lib_info.package info
    with
    | None -> [ Private_lib (Odoc.lib_unique_name (lib :> Lib.t)) ]
    | Some _pkg ->
      (match Lib_name.analyze (Lib.name (lib :> Lib.t)) with
       | Private (_, _) -> [ Private_lib (Odoc.lib_unique_name (lib :> Lib.t)) ]
       | Public (pkg, rest) ->
         List.fold_left
           ~f:(fun acc s -> Sub_dir s :: acc)
           rest
           ~init:[ Sub_dir (Package.Name.to_string pkg); Top_dir Local_packages ])
  ;;

  let of_local_package pkg =
    [ Sub_dir (Package.Name.to_string pkg); Top_dir Local_packages ]
  ;;

  let of_external_loc maps (loc : Dune_package.External_location.t) : t option =
    let open Option.O in
    let* top, local =
      match loc with
      | Relative_to_stdlib local_path -> Some (Relative_to_stdlib, local_path)
      | Relative_to_findlib (findlib_path, local_path) ->
        let+ n = Path.Map.find maps.findlib_paths findlib_path in
        Relative_to_findlib (n, findlib_path), local_path
      | Absolute _ -> None
    in
    let s = Path.Local.explode local in
    let index =
      List.fold_left s ~f:(fun acc s -> Sub_dir s :: acc) ~init:[ Top_dir top ]
    in
    Some index
  ;;

  let of_external_lib maps lib =
    let name = Lib.name lib in
    match
      let open Option.O in
      let* loc = Lib_name.Map.find maps.loc_of_lib name in
      of_external_loc maps loc
    with
    | Some loc -> loc
    | None ->
      Log.info [ Pp.textf "Argh lib ex loc: %s" (Lib_name.to_string name) ];
      [ Sub_dir (Lib_name.to_string (Lib.name lib)); Top_dir Other ]
  ;;

  let of_pkg maps pkg =
    match
      let open Option.O in
      let* loc = Package.Name.Map.find maps.loc_of_pkg pkg in
      of_external_loc maps loc
    with
    | Some loc -> loc
    | None -> of_local_package pkg
  ;;
end
