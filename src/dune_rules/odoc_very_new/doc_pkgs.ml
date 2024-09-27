open Import
open Memo.O
module Ext_loc_map = Map.Make (Dune_package.External_location)

type ext_loc_maps =
  { findlib_paths : int Path.Map.t
  ; loc_of_pkg : Dune_package.External_location.t Package.Name.Map.t
  ; loc_of_lib : Dune_package.External_location.t Lib_name.Map.t
  ; libs_of_loc : (Dune_package.Lib.t * Lib.t) Lib_name.Map.t Ext_loc_map.t
  }

let stdlib_lib ctx =
  let* public_libs = Scope.DB.public_libs ctx in
  Lib.DB.find public_libs (Lib_name.of_string "stdlib")
;;

let lib_equal l1 l2 = Lib.compare l1 l2 |> Ordering.is_eq

let is_public lib =
  match Lib.Local.to_lib lib |> Lib.info |> Lib_info.status with
  | Installed_private -> false
  | Installed -> true
  | Public _ -> true
  | Private (_project, _) -> false
;;

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

  (** We need to know if every single library within a findlib package dir is
      confined to its own subdirectory (ie, no two libraries are found in the
      same dir), and that we have information about the modules of every
      library within the tree. If this is not the case, we'll fall back to a
      less specific mode that simply documents the modules found within each
      dir without assigning them a library. *)
  val classify_location : ext_loc_maps -> Ext_loc_map.key -> local_dir_type Memo.t
end = struct
  (* Here we classify top-level dirs in the findlib paths. They are either
     packages built by dune for which we have all the info we need -
     a [Modules.t] value - or there exists one (or more!) libraries within
     the directory that don't satisfy this, and these are labelled
     fallback directories. *)
  exception Fallback

  (* The fallback is simply a map of subdirectory to list of libraries
     found in that subdir. This is the value returned by [libs_of_local_dir] *)
  type fallback = { libs : Lib.t Lib_name.Map.t }

  let fallback_to_dyn x =
    let open Dyn in
    record [ "libs", Lib_name.Map.to_dyn Lib.to_dyn x.libs ]
  ;;

  let fallback_equal f1 f2 = Lib_name.Map.equal ~equal:Lib.equal f1.libs f2.libs

  let fallback_hash f =
    Lib_name.Map.fold f.libs ~init:0 ~f:(fun lib acc -> Poly.hash (acc, Lib.hash lib))
  ;;

  type local_dir_type =
    | Nothing
    | Dune_with_modules of (Package.Name.t * Lib.t)
    | Fallback of fallback

  (* We need to know if every single library within a findlib package dir is
     confined to its own subdirectory (ie, no two libraries are found in the
     same dir), and that we have information about the modules of every
     library within the tree. If this is not the case, we'll fall back to a
     less specific mode that simply documents the modules found within each
     dir without assigning them a library. *)
  let classify_location maps location =
    match Ext_loc_map.find maps.libs_of_loc location with
    | None ->
      Log.info
        [ Pp.textf
            "classify_local_dir: No lib at this location: %s"
            (Dyn.to_string (Dune_package.External_location.to_dyn location))
        ];
      Memo.return Nothing
    | Some libs ->
      (try
         let pkg, lib =
           match Lib_name.Map.values libs with
           | [ (dlib, lib) ] ->
             let info = Dune_package.Lib.info dlib in
             let pkg = Lib_name.package_name (Lib_info.name info) in
             (match
                let mods_opt = Lib_info.modules info in
                mods_opt, Lib_info.entry_modules info
              with
              | External (Some _), External (Ok _) -> pkg, lib
              | _ -> raise Fallback)
           | _ -> raise Fallback
         in
         Memo.return (Dune_with_modules (pkg, lib))
       with
       | Fallback ->
         let libs = Lib_name.Map.map libs ~f:snd in
         Memo.return (Fallback { libs }))
  ;;
end

(* Returns a [ext_loc_maps] value that contains all the information
   needed to find the location of a library or package stored externally
   to the current workspace.

   Note that this list may contain entries for libraries that are also
   in the dune workspace, if they happen to be installed elsewhere. These
   are filtered out in the `Valid` module below, and this general function
   should not be used.

   Note: There are two reasons why we have a fallback mechanism for
   non-dune installed packages - first that there is more than one library
   in a particular directory, and the second is that we don't have a
   [Modules.t] value for the library. They essentially boil down to the
   problem that it's very hard to know which modules correspond to which
   library given a simple include path. Introspecting the cmas isn't
   sufficient because of the existence of cmi-only modules. A potential
   improvement is to handle the case of only one library per directory,
   though this is likely only of limited benefit. If we do this, we would
   need to modify this function to work on _all_ packages in the findlib
   directory so we can correctly identify those directories containing
   multiple libs.
*)
let libs_maps_def =
  let f (ctx, libs) =
    let* db = Scope.DB.public_libs (Context.name ctx)
    and* all_packages_entries =
      let* findlib = Findlib.create (Context.name ctx) in
      Memo.parallel_map ~f:(Findlib.find findlib) libs
      >>| List.filter_map ~f:Result.to_option
    in
    let* findlib_paths =
      let+ findlib_paths_list = Context.findlib_paths ctx in
      List.fold_left findlib_paths_list ~init:(0, Path.Map.empty) ~f:(fun (i, acc) path ->
        match Path.Map.add acc path i with
        | Ok acc -> i + 1, acc
        | Error _ ->
          Log.info [ Pp.textf "Error adding findlib path to map" ];
          i + 1, acc)
      |> snd
    in
    let init =
      { findlib_paths
      ; loc_of_pkg = Package.Name.Map.empty
      ; loc_of_lib = Lib_name.Map.empty
      ; libs_of_loc = Ext_loc_map.empty
      }
    in
    Memo.List.fold_left all_packages_entries ~init ~f:(fun maps entry ->
      match (entry : Dune_package.Entry.t) with
      | Deprecated_library_name _ | Hidden_library _ -> Memo.return maps
      | Dune_package.Entry.Library l ->
        (match Dune_package.Lib.external_location l with
         | None ->
           Log.info
             [ Pp.textf
                 "No location for lib %s"
                 (Dune_package.Lib.info l |> Lib_info.name |> Lib_name.to_string)
             ];
           Memo.return maps
         | Some location ->
           let info = Dune_package.Lib.info l in
           let name = Lib_info.name info in
           let pkg = Lib_info.package info in
           Lib.DB.find_lib_id db (Lib_info.lib_id info)
           >>| (function
            | None -> maps
            | Some lib ->
              let loc_of_lib =
                match Lib_name.Map.add maps.loc_of_lib name location with
                | Ok l -> l
                | Error _ ->
                  (* I don't expect this should ever happen *)
                  Log.info
                    [ Pp.textf
                        "Error adding lib %s to loc_of_lib map"
                        (Lib_name.to_string name)
                    ];
                  maps.loc_of_lib
              in
              let loc_of_pkg =
                match pkg with
                | None -> maps.loc_of_pkg
                | Some pkg_name ->
                  (match Package.Name.Map.add maps.loc_of_pkg pkg_name location with
                   | Ok l -> l
                   | Error _ ->
                     (* There will be lots of repeated packages, no problem here *)
                     maps.loc_of_pkg)
              in
              let update_fn = function
                | None -> Some (Lib_name.Map.singleton name (l, lib))
                | Some libs ->
                  (match Lib_name.Map.add libs name (l, lib) with
                   | Ok libs -> Some libs
                   | Error _ ->
                     Log.info
                       [ Pp.textf
                           "Error adding lib %s to libs_of_loc map"
                           (Lib_name.to_string name)
                       ];
                     Some libs)
              in
              let libs_of_loc =
                Ext_loc_map.update maps.libs_of_loc location ~f:update_fn
              in
              { maps with loc_of_lib; loc_of_pkg; libs_of_loc })))
  in
  let module Input = struct
    type t = Context.t * Lib_name.t list

    let equal (c1, l1) (c2, l2) = Context.equal c1 c2 && List.equal Lib_name.equal l1 l2
    let to_dyn = Dyn.pair Context.to_dyn (Dyn.list Lib_name.to_dyn)
    let hash (c, l) = Poly.hash (Context.hash c, List.hash Lib_name.hash l)
  end
  in
  Memo.create "odoc_lib_maps" ~input:(module Input) f
;;

let libs_maps_general ctx libs = Memo.exec libs_maps_def (ctx, libs)

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
end = struct
  (* These functions return a allowlist of libraries and packages that
     should be documented. There is one single function that performs this
     task because there needs to be an exact correspondence at various points
     in the process - e.g. the indexes need to know exactly which libraries will
     be documented and where. *)
  let valid_libs_and_packages =
    let run (ctx, all, projects) =
      let* libs_and_pkgs =
        let* mask =
          let+ mask = Dune_load.mask () in
          Option.map ~f:Package.Name.Map.keys mask
        in
        Scope.DB.with_all ctx ~f:(fun find ->
          Memo.List.fold_left projects ~init:([], []) ~f:(fun (libs_acc, pkg_acc) proj ->
            let* vendored = Source_tree.is_vendored (Dune_project.root proj) in
            if vendored
            then Memo.return (libs_acc, pkg_acc)
            else (
              let lib_db =
                let scope = find proj in
                Scope.libs scope
              in
              let+ libs_acc =
                let+ libs = Lib.DB.all lib_db in
                let libs =
                  match mask with
                  | None -> libs
                  | Some mask ->
                    Lib.Set.filter libs ~f:(fun lib ->
                      let info = Lib.info lib in
                      match Lib_info.package info with
                      | Some p -> List.mem ~equal:Package.Name.equal mask p
                      | None -> false)
                in
                libs :: libs_acc
              in
              let pkg_acc =
                let pkgs =
                  let proj_pkgs = Dune_project.packages proj |> Package.Name.Map.keys in
                  match mask with
                  | None -> proj_pkgs
                  | Some m ->
                    List.filter ~f:(List.mem ~equal:Package.Name.equal m) proj_pkgs
                in
                pkgs @ pkg_acc
              in
              libs_acc, pkg_acc)))
      in
      let* libs, packages = libs_and_pkgs in
      let+ libs_list =
        let+ libs_list =
          let+ libs_list =
            let* stdlib = stdlib_lib (Context.name ctx) in
            Memo.parallel_map libs ~f:(fun libs ->
              Lib.Set.fold ~init:(Memo.return []) libs ~f:(fun lib acc ->
                let* acc = acc in
                let+ libs =
                  let* libs = Lib.closure (lib :: Option.to_list stdlib) ~linking:false in
                  Resolve.read_memo libs
                in
                libs :: acc))
          in
          libs_list
          |> List.concat
          |> List.concat
          |> Lib.Set.of_list
          |> Lib.Set.to_list
          |> List.filter ~f:(fun lib ->
            let is_impl = Lib.info lib |> Lib_info.implements |> Option.is_some in
            not is_impl)
        in
        if all
        then libs_list
        else
          List.filter libs_list ~f:(fun lib ->
            match Lib.Local.of_lib lib with
            | None -> false
            | Some l -> is_public l)
      in
      libs_list, packages
    in
    let module Input = struct
      type t = Context.t * bool * Dune_project.t list

      let equal (c1, b1, ps1) (c2, b2, ps2) =
        Context.equal c1 c2 && List.equal Dune_project.equal ps1 ps2 && b1 = b2
      ;;

      let hash (c, b, ps) = Poly.hash (Context.hash c, b, List.hash Dune_project.hash ps)
      let to_dyn _ = Dyn.Opaque
    end
    in
    Memo.create "libs_and_packages" ~input:(module Input) run
  ;;

  let get ctx ~all =
    let* projects = Dune_load.projects () in
    Memo.exec valid_libs_and_packages (ctx, all, projects)
  ;;

  (* Some functions to filter various values containing libraries
     against the allowlist *)

  let filter_libs ctx ~all libs =
    let+ valid_libs, _ = get ctx ~all in
    List.filter libs ~f:(fun l -> List.mem valid_libs l ~equal:lib_equal)
  ;;

  let filter_fallback_libs ctx ~all libs =
    let+ valid_libs, _ = get ctx ~all in
    Lib_name.Map.filter libs ~f:(fun lib -> List.mem valid_libs lib ~equal:lib_equal)
  ;;

  let libs_maps ctx ~all =
    let* libs, _packages = get ctx ~all in
    let libs =
      List.filter_map
        ~f:(fun l -> if Lib.is_local l then None else Some (Lib.name l))
        libs
    in
    libs_maps_general ctx libs
  ;;

  (* It's handy for the toplevel index generation to be able to construct
     a categorized list of all the packages, the libraries and everything
     else that will end up being documented. *)
  type categorized =
    { packages : Package.Name.Set.t
    ; local : Lib.Local.t Lib_name.Map.t
    ; externals : Classify.local_dir_type Ext_loc_map.t
    }

  let empty_categorized =
    { packages = Package.Name.Set.empty
    ; local = Lib_name.Map.empty
    ; externals = Ext_loc_map.empty
    }
  ;;

  let get_categorized_memo =
    let run (ctx, all) =
      let* libs, packages = get ctx ~all in
      let init =
        Memo.return
          { empty_categorized with packages = Package.Name.Set.of_list packages }
      in
      List.fold_left libs ~init ~f:(fun cats lib ->
        let* cats = cats in
        match Lib.Local.of_lib lib with
        | Some llib ->
          let local =
            match Lib_name.Map.add cats.local (Lib.name (llib :> Lib.t)) llib with
            | Ok l -> l
            | Error _ ->
              Log.info
                [ Pp.textf
                    "Error adding local library %s to categorized map"
                    (Lib.name (llib :> Lib.t) |> Lib_name.to_string)
                ];
              cats.local
          in
          Memo.return { cats with local }
        | None ->
          let* maps = libs_maps ctx ~all in
          (match Lib_name.Map.find maps.loc_of_lib (Lib.name lib) with
           | None ->
             Log.info
               [ Pp.textf "No location for lib: %s" (Lib.name lib |> Lib_name.to_string) ];
             Memo.return cats
           | Some location ->
             let* classification = Classify.classify_location maps location in
             let f (old : Classify.local_dir_type option) =
               match old with
               | None -> Some classification
               | Some Nothing -> old
               | Some (Fallback _) -> old
               | Some (Dune_with_modules _) ->
                 let loc_str =
                   Dyn.to_string (Dune_package.External_location.to_dyn location)
                 in
                 Log.info
                   [ Pp.textf
                       "Duplicate 'Dune_with_modules' library found in location %s"
                       loc_str
                   ];
                 old
             in
             let externals = Ext_loc_map.update cats.externals location ~f in
             Memo.return { cats with externals }))
    in
    let module Input = struct
      type t = Context.t * bool

      let equal (c1, b1) (c2, b2) = Context.equal c1 c2 && b1 = b2
      let hash (c, b) = Poly.hash (Context.hash c, b)
      let to_dyn _ = Dyn.Opaque
    end
    in
    Memo.create "categorized" ~input:(module Input) run
  ;;

  let get_categorized ctx all = Memo.exec get_categorized_memo (ctx, all)
end
