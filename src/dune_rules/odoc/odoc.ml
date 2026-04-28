open Import
open Memo.O
module Gen_rules = Build_config.Gen_rules

let ( ++ ) = Path.Build.relative

module Target = Odoc_target
module Doc_mode = Odoc_paths.Doc_mode
module Scope_id = Odoc_scope.Scope_id

type odoc_output =
  | Odoc
  | Odocls

let add_rule sctx =
  let dir = Super_context.context sctx |> Context.build_dir in
  Super_context.add_rule sctx ~dir
;;

module Paths = Odoc_paths

module Output_format = struct
  type t = Paths.output_format =
    | Html
    | Json
    | Markdown

  let all = [ Html; Json; Markdown ]

  let args = function
    | Html -> Command.Args.empty
    | Json -> A "--as-json"
    | Markdown -> Command.Args.empty
  ;;

  let alias_name t mode =
    match t, mode with
    | Html, Doc_mode.Local_only -> Alias0.doc
    | Html, Doc_mode.Full -> Alias0.doc_full
    | Json, Doc_mode.Local_only -> Alias0.doc_json
    | Json, Doc_mode.Full -> Alias0.doc_json_full
    | Markdown, Doc_mode.Local_only -> Alias0.doc_md
    | Markdown, Doc_mode.Full -> Alias0.doc_md_full
  ;;

  let alias t ~mode ~dir = Alias.make (alias_name t mode) ~dir
end

module Artifact = Odoc_artifact

module Dep : sig
  val odoc_all_alias : dir:Path.Build.t -> Alias.t
  val format_alias : Output_format.t -> Doc_mode.t -> Context.t -> 'a Target.t -> Alias.t
  val add_file_deps : Alias.t -> Path.t list -> unit Memo.t
  val add_odoc_all_deps : Alias.t -> dirs:Path.Build.t list -> unit Memo.t

  (** [deps ctx pkg libraries] returns all odoc dependencies of [libraries]. If
      [libraries] are all part of a package [pkg], then the odoc dependencies of
      the package are also returned*)
  val deps
    :  Context.t
    -> Package.Name.t list
    -> Lib.t list Resolve.t
    -> unit Action_builder.t

  (*** [setup_deps ctx target odocs] Adds [odocs] as dependencies for [target].
    These dependencies may be used using the [deps] function *)
  val setup_deps : Context.t -> 'a Target.t -> Path.Set.t -> unit Memo.t
end = struct
  let odoc_all_alias ~dir = Alias.make (Alias.Name.of_string ".odoc-all") ~dir

  let odoc_all_alias_for_target : type a. Context.t -> a Target.t -> Alias.t =
    fun ctx target -> odoc_all_alias ~dir:(Paths.odocs ctx target)
  ;;

  let format_alias
    : type a. Output_format.t -> Doc_mode.t -> Context.t -> a Target.t -> Alias.t
    =
    fun f mode ctx m ->
    let dir = Paths.output ctx mode f m in
    Output_format.alias f ~mode ~dir
  ;;

  let add_file_deps alias files =
    Rules.Produce.Alias.add_deps alias (Action_builder.paths files)
  ;;

  let add_odoc_all_deps alias ~dirs =
    let dep_set =
      List.map dirs ~f:(fun dir -> Dune_engine.Dep.alias (odoc_all_alias ~dir))
      |> Dune_engine.Dep.Set.of_list
    in
    Rules.Produce.Alias.add_deps alias (Action_builder.deps dep_set)
  ;;

  let deps ctx pkgs requires =
    let open Action_builder.O in
    let* libs = Resolve.read requires in
    let* pkg_discovery = Action_builder.of_memo (Package_discovery.create ~context:ctx) in
    Action_builder.deps
      (let init =
         List.fold_left pkgs ~init:Dep.Set.empty ~f:(fun acc p ->
           Dep.Set.add acc (Dep.alias (odoc_all_alias ~dir:(Paths.odocs ctx (Pkg p)))))
       in
       List.fold_left libs ~init ~f:(fun acc (lib : Lib.t) ->
         let info = Lib.info lib in
         (* Skip implementations of virtual libraries - they don't have docs *)
         match Lib_info.implements info with
         | Some _ -> acc
         | None ->
           (match Lib.Local.of_lib lib with
            | None ->
              let lib_pkg_opt = Package_discovery.package_of_library pkg_discovery lib in
              (match lib_pkg_opt with
               | Some lib_pkg ->
                 let dir =
                   Paths.root ctx
                   ++ "_odoc"
                   ++ Package.Name.to_string lib_pkg
                   ++ Lib_name.to_string (Lib.name lib)
                 in
                 Dep.Set.add acc (Dep.alias (odoc_all_alias ~dir))
               | None -> acc)
            | Some local_lib ->
              let lib_t = Lib.Local.to_lib local_lib in
              let target =
                match Lib_info.package info with
                | Some pkg -> Target.Lib (pkg, lib_t)
                | None ->
                  let lib_unique_name = Odoc_scope.lib_unique_name local_lib in
                  Target.Private_lib (lib_unique_name, lib_t)
              in
              let dir = Paths.odocs ctx target in
              Dep.Set.add acc (Dep.alias (odoc_all_alias ~dir)))))
  ;;

  let setup_deps : type a. Context.t -> a Target.t -> Path.Set.t -> unit Memo.t =
    fun ctx m files ->
    add_file_deps (odoc_all_alias_for_target ctx m) (Path.Set.to_list files)
  ;;
end

let get_workspace_packages = Odoc_discovery.get_workspace_packages

let generate_remap_mappings_simple pkg_discovery ~packages =
  let* packages_to_remap =
    Memo.List.filter (Package.Name.Set.to_list packages) ~f:(fun pkg ->
      let+ is_local = Odoc_discovery.is_local_package pkg in
      not is_local)
  in
  let+ mappings =
    Memo.List.map packages_to_remap ~f:(fun pkg_name ->
      let+ version_opt = Package_discovery.version_of_package pkg_discovery pkg_name in
      let version = Option.value version_opt ~default:"latest" in
      let pkg_path = Package.Name.to_string pkg_name in
      let pkg_url = Printf.sprintf "https://ocaml.org/p/%s/%s/doc/" pkg_path version in
      pkg_path ^ "/", pkg_url)
  in
  mappings
;;

let write_remap_file sctx ~remap_file ~mappings =
  let contents =
    String.concat
      ~sep:"\n"
      (List.map mappings ~f:(fun (local, remote) -> Printf.sprintf "%s:%s" local remote))
  in
  add_rule sctx (Action_builder.write_file remap_file contents)
;;

module Flags = struct
  type warnings = Dune_env.Odoc.warnings =
    | Fatal
    | Nonfatal

  type sidebar = Dune_env.Odoc.sidebar =
    | Global
    | Per_package

  type support = Dune_env.Odoc.support =
    | Root
    | Per_package

  type t =
    { warnings : warnings
    ; sidebar : sidebar
    ; support : support
    }

  let default = { warnings = Nonfatal; sidebar = Global; support = Root }

  let get_memo ~dir =
    Env_stanza_db.value ~default ~dir ~f:(fun config ->
      let warnings = Option.value config.odoc.warnings ~default:default.warnings in
      let sidebar = Option.value config.odoc.sidebar ~default:default.sidebar in
      let support = Option.value config.odoc.support ~default:default.support in
      Memo.return (Some { warnings; sidebar; support }))
  ;;

  let get ~dir = get_memo ~dir |> Action_builder.of_memo
end

(* Resolved CLI flags from the env stanza, with OSL expansion *)
type cli_flags =
  { compile : string list Action_builder.t
  ; link : string list Action_builder.t
  ; html : string list Action_builder.t
  }

let cli_flags_env =
  let f =
    Env_stanza_db_flags.flags
      ~name:"odoc-cli-flags-env"
      ~root:(fun _ctx _project ->
        Memo.return
          { compile = Action_builder.return []
          ; link = Action_builder.return []
          ; html = Action_builder.return []
          })
      ~f:(fun ~parent expander (config : Dune_env.config) ->
        let+ parent = parent in
        let eval osl ~default =
          Expander.expand_and_eval_set expander osl ~standard:default
        in
        { compile = eval config.odoc.flags ~default:parent.compile
        ; link = eval config.odoc.link_flags ~default:parent.link
        ; html = eval config.odoc.html_flags ~default:parent.html
        })
  in
  fun ~dir ->
    let* () = Memo.return () in
    (Staged.unstage f) dir
;;

let odoc_base_flags quiet build_dir =
  let open Action_builder.O in
  let+ conf = Flags.get ~dir:build_dir in
  match conf.warnings with
  | Fatal ->
    (* if quiet has been passed, we're running odoc on an external
       artifact (e.g. stdlib.cmti) - so no point in warn-error *)
    if quiet then Command.Args.S [] else A "--warn-error"
  | Nonfatal -> S []
;;

let odoc_dev_tool_exe_path_building_if_necessary () =
  let open Action_builder.O in
  let path = Path.build (Pkg_dev_tool.exe_path Odoc) in
  let+ () = Action_builder.path path in
  Ok path
;;

let odoc_program sctx dir =
  let open Action_builder.O in
  let* lock_dir_exists =
    Action_builder.of_memo
      (match Config.get Compile_time.lock_dev_tools with
       | `Enabled -> Memo.return true
       | `Disabled ->
         (* even if lock_dev_tools is disabled, there might be a lock dir
            created by `dune tools install odoc` *)
         let path = Lock_dir.dev_tool_external_lock_dir Odoc in
         Fs_memo.dir_exists (Path.Outside_build_dir.External path))
  in
  match lock_dir_exists with
  | true -> odoc_dev_tool_exe_path_building_if_necessary ()
  | false ->
    Super_context.resolve_program
      sctx
      ~dir
      ~where:Original_path
      "odoc"
      ~loc:None
      ~hint:"opam install odoc"
;;

let run_odoc sctx ?dir command ~quiet ~flags_for args =
  let ctx = Super_context.context sctx in
  let build_dir = Context.build_dir ctx in
  let program = odoc_program sctx build_dir in
  let dir = Path.build (Option.value dir ~default:(Paths.root ctx)) in
  let base_flags =
    let open Action_builder.O in
    let* () = Action_builder.return () in
    match flags_for with
    | None -> Action_builder.return Command.Args.empty
    | Some path -> odoc_base_flags quiet path
  in
  (* Depend on ODOC_SYNTAX env var and the odoc binary itself.
     The binary dependency ensures rules rebuild when odoc is updated. *)
  let deps =
    let open Action_builder.O in
    let* () = Action_builder.env_var "ODOC_SYNTAX" in
    let* prog_result = program in
    match prog_result with
    | Ok path -> Action_builder.path path
    | Error _ -> Action_builder.return ()
  in
  let open Action_builder.With_targets.O in
  let run =
    Action_builder.with_no_targets deps
    >>> Command.run_dyn_prog ~dir program [ A command; Dyn base_flags; S args ]
  in
  if quiet
  then
    Action_builder.With_targets.map run ~f:(fun action ->
      Action.Full.map action ~f:Action.ignore_outputs)
  else run
;;

let get_lib_paths ctx ~stdlib_opt requires pkg_discovery =
  let open Resolve.O in
  let+ libs = requires in
  let libs =
    match stdlib_opt with
    | Some stdlib ->
      if List.exists libs ~f:(fun lib -> Lib_name.equal (Lib.name lib) (Lib.name stdlib))
      then libs
      else stdlib :: libs
    | None -> libs
  in
  List.filter_map libs ~f:(fun lib ->
    match Lib.Local.of_lib lib with
    | None ->
      let lib_pkg_opt = Package_discovery.package_of_library pkg_discovery lib in
      Option.map lib_pkg_opt ~f:(fun lib_pkg ->
        lib, Paths.odocs ctx (Target.Lib (lib_pkg, lib)))
    | Some local_lib ->
      let lib_t = Lib.Local.to_lib local_lib in
      let lib_info = Lib.info lib_t in
      let target =
        match Lib_info.package lib_info with
        | Some pkg -> Target.Lib (pkg, lib_t)
        | None ->
          let lib_unique_name = Odoc_scope.lib_unique_name local_lib in
          Target.Private_lib (lib_unique_name, lib_t)
      in
      Some (lib, Paths.odocs ctx target))
;;

let stdlib_lib ctx =
  let* public_libs = Scope.DB.public_libs ctx in
  Lib.DB.find public_libs (Lib_name.of_string "stdlib")
;;

(* Generate -L library:path flags for odoc link
   These tell odoc where to find .odocl files for library dependencies *)
let odoc_lib_flags ctx ~stdlib_opt requires pkg_discovery =
  Resolve.args
    (let open Resolve.O in
     let+ lib_paths = get_lib_paths ctx ~stdlib_opt requires pkg_discovery in
     (* Deduplicate by library name and make paths relative *)
     let doc_root = Paths.root ctx in
     let lib_paths_map =
       List.fold_left lib_paths ~init:Lib_name.Map.empty ~f:(fun acc (lib, odoc_dir) ->
         let lib_name = Lib.name lib in
         if Lib_name.Map.mem acc lib_name
         then acc
         else (
           let lib_name_str = Lib_name.to_string lib_name in
           (* Compute path relative to doc_root using proper path functions *)
           let odoc_path_rel =
             Path.reach (Path.build odoc_dir) ~from:(Path.build doc_root)
           in
           let lib_path_arg = lib_name_str ^ ":" ^ odoc_path_rel in
           Lib_name.Map.set acc lib_name lib_path_arg))
     in
     (* Convert map to args *)
     let lib_args =
       Lib_name.Map.values lib_paths_map
       |> List.concat_map ~f:(fun lib_path_arg -> [ Command.Args.A "-L"; A lib_path_arg ])
     in
     Command.Args.S lib_args)
;;

(* Get package dependencies from odoc-config.sexp for a set of packages *)
let get_config_package_deps pkg_discovery pkgs =
  List.concat_map pkgs ~f:(fun pkg ->
    let config = Package_discovery.config_of_package pkg_discovery pkg in
    config.Odoc_config.deps.packages)
;;

(* Generate -P package:path flags for odoc link.
   These tell odoc where to find .odoc files for package dependencies.
   In addition to explicit config deps, we derive packages from the library
   closure (requires) so that transitive library dependencies like odoc-parser
   (a dependency of odoc) get -P flags even when they aren't listed explicitly
   in :with-doc deps or in odoc-config.sexp. *)
let odoc_pkg_flags ctx pkg_discovery ~current_pkg_opt ~artifact_config ~requires =
  let doc_root = Paths.root ctx in
  Resolve.args
    (let open Resolve.O in
     let+ libs = requires in
     (* Collect direct packages (config deps + current package) and their transitive config deps *)
     let direct_pkgs =
       artifact_config.Odoc_config.deps.packages @ Option.to_list current_pkg_opt
     in
     let config_pkgs = get_config_package_deps pkg_discovery direct_pkgs in
     (* Also derive packages from the library closure *)
     let pkgs_from_libs =
       List.filter_map libs ~f:(fun lib ->
         match Lib.Local.of_lib lib with
         | Some local_lib -> Lib_info.package (Lib.info (Lib.Local.to_lib local_lib))
         | None -> Package_discovery.package_of_library pkg_discovery lib)
     in
     let all_pkgs = direct_pkgs @ config_pkgs @ pkgs_from_libs in
     (* Build unique package map with their odoc paths *)
     let pkg_paths =
       List.fold_left all_pkgs ~init:Package.Name.Map.empty ~f:(fun acc pkg ->
         let odoc_dir = Paths.odocs ctx (Pkg pkg) in
         let path = Path.reach (Path.build odoc_dir) ~from:(Path.build doc_root) in
         Package.Name.Map.set acc pkg path)
     in
     (* Generate -P pkg:path flags *)
     let flags =
       Package.Name.Map.to_list_map pkg_paths ~f:(fun pkg path ->
         [ Command.Args.A "-P"; A (Package.Name.to_string pkg ^ ":" ^ path) ])
       |> List.concat
     in
     Command.Args.S flags)
;;

(* Compute library dependencies for an artifact.

   Returns a pair (closure, external_requires):
   - closure: Full transitive closure of library dependencies including self
   - external_requires: Transitive dependencies excluding self and same-package libraries

   Handles the special case of stdlib: when compiling stdlib itself, we don't add
   stdlib to its own dependency list to avoid cycles. *)
let compute_artifact_library_deps ctx ~artifact ~package_lib_names =
  (* Get stdlib for dependency resolution *)
  let* stdlib_opt = stdlib_lib (Context.name ctx) in
  (* Check if this artifact is part of stdlib *)
  let is_stdlib_artifact =
    match stdlib_opt with
    | Some stdlib -> Lib_name.equal (Lib.name stdlib) (Artifact.lib_name artifact)
    | None -> false
  in
  (* Get TRANSITIVE closure of dependencies (not just direct requires) *)
  let* closure =
    match Artifact.lib artifact with
    | Some lib ->
      (* Include stdlib in the closure unless we're compiling stdlib itself *)
      let libs_to_close =
        if is_stdlib_artifact then [ lib ] else lib :: Option.to_list stdlib_opt
      in
      Lib.closure libs_to_close ~linking:false ~for_:Compilation_mode.Ocaml
    | None -> Memo.return (Resolve.return [])
    (* Package-level and toplevel artifacts have no library dependencies *)
  in
  (* For library dependency aliases, filter out:
     1. The library itself (to avoid self-dependency)
     2. Other libraries in the same package (to avoid circular dependencies)
     Module-level dependencies from odoc compile-deps will handle the actual file dependencies.
     This prevents circular dependencies when libraries in the same package have circular module deps
     (e.g., OCaml's compiler-libs where compiler-libs.common's Meta depends on compiler-libs.bytecomp's Instruct). *)
  let external_requires =
    match Artifact.lib artifact with
    | Some lib ->
      Resolve.map closure ~f:(fun all_libs ->
        List.filter all_libs ~f:(fun dep_lib ->
          let dep_lib_name = Lib.name dep_lib in
          (not (Lib_name.equal dep_lib_name (Lib.name lib)))
          && not (Lib_name.Set.mem package_lib_names dep_lib_name)))
    | None -> closure
  in
  Memo.return (closure, external_requires)
;;

let odoc_include_flags ctx pkg requires pkg_discovery =
  let open Memo.O in
  let* stdlib_opt = stdlib_lib (Context.name ctx) in
  let args =
    Resolve.args
      (let open Resolve.O in
       let+ lib_paths = get_lib_paths ctx ~stdlib_opt requires pkg_discovery in
       let paths =
         List.fold_left lib_paths ~init:Path.Set.empty ~f:(fun paths (_lib, path) ->
           Path.Set.add paths (Path.build path))
       in
       let paths =
         match pkg with
         | Some p -> Path.Set.add paths (Path.build (Paths.odocs ctx (Pkg p)))
         | None -> paths
       in
       Command.Args.S
         (List.concat_map (Path.Set.to_list paths) ~f:(fun dir ->
            [ Command.Args.A "-I"; Path dir ])))
  in
  Memo.return args
;;

let compute_intra_library_module_deps sctx ~ctx ~artifact ~lib_artifacts_by_module =
  let source_file = Artifact.source_file artifact in
  match Artifact.get_kind artifact with
  | Page _ | Asset _ -> Memo.return (Action_builder.return ())
  | Module ({ module_name; _ }, _) ->
    let module_name_str = Module_name.to_string module_name in
    let output_dir = Artifact.odoc_dir ctx artifact in
    let deps_file = Path.Build.relative output_dir (module_name_str ^ ".deps") in
    let program = odoc_program sctx (Context.build_dir ctx) in
    let+ () =
      let run_compile_deps =
        Command.run_dyn_prog
          program
          ~dir:(Path.build (Context.build_dir ctx))
          ~stdout_to:deps_file
          [ A "compile-deps"; Dep source_file ]
      in
      add_rule sctx run_compile_deps
    in
    let open Action_builder.O in
    let* lines = Action_builder.lines_of (Path.build deps_file) in
    let dep_modules =
      List.filter_map lines ~f:(fun line ->
        match String.split ~on:' ' line with
        | [ m; _hash ] -> Some (Module_name.of_checked_string m)
        | _ -> None)
    in
    let current_module_name =
      match Artifact.get_kind artifact with
      | Module ({ module_name; _ }, _) -> Some module_name
      | Page _ | Asset _ -> None
    in
    let dep_odoc_files =
      List.filter_map dep_modules ~f:(fun dep_module ->
        match current_module_name with
        | Some current when Module_name.equal current dep_module -> None
        | _ -> Module_name.Map.find lib_artifacts_by_module dep_module)
    in
    Dune_engine.Dep.Set.of_files dep_odoc_files |> Action_builder.deps
;;

let compile_asset_artifact sctx ~artifact =
  let ctx = Super_context.context sctx in
  let asset_name =
    match Artifact.asset_name artifact with
    | Some name -> name
    | None -> Code_error.raise "compile_asset_artifact called on non-asset" []
  in
  let parent_id = Artifact.parent_id artifact in
  let run_odoc =
    Action_builder.With_targets.add
      ~file_targets:[ Artifact.odoc_file ctx artifact ]
      (run_odoc
         sctx
         "compile-asset"
         ~quiet:false
         ~flags_for:None
         [ Command.Args.A "--output-dir"
         ; Command.Args.A "_odoc"
         ; Command.Args.A "--parent-id"
         ; Command.Args.A parent_id
         ; Command.Args.A "--name"
         ; Command.Args.A asset_name
         ])
  in
  add_rule sctx run_odoc
;;

let compile_artifact sctx ~artifact ~lib_artifacts_by_module ~package_lib_names =
  let ctx = Super_context.context sctx in
  (* Handle assets specially - they use compile-asset, not compile *)
  match Artifact.get_kind artifact with
  | Asset _ -> compile_asset_artifact sctx ~artifact
  | Module _ | Page _ ->
    let source_file = Artifact.source_file artifact in
    let* module_deps =
      compute_intra_library_module_deps sctx ~ctx ~artifact ~lib_artifacts_by_module
    in
    let* closure, external_requires =
      compute_artifact_library_deps ctx ~artifact ~package_lib_names
    in
    let* pkg_discovery = Package_discovery.create ~context:ctx in
    let* include_flags = odoc_include_flags ctx None closure pkg_discovery in
    let* should_suppress = Artifact.should_suppress_output artifact in
    let* cli_flags = cli_flags_env ~dir:(Context.build_dir ctx) in
    let lib_deps = Dep.deps ctx [] external_requires in
    let run_odoc =
      let open Action_builder.With_targets.O in
      Action_builder.with_no_targets module_deps
      >>> Action_builder.with_no_targets lib_deps
      >>> Action_builder.With_targets.add
            ~file_targets:[ Artifact.odoc_file ctx artifact ]
            (run_odoc
               sctx
               "compile"
               ~quiet:should_suppress
               ~flags_for:(Some (Artifact.odoc_file ctx artifact))
               [ include_flags
               ; (let parent = Artifact.parent_id artifact in
                  if String.is_empty parent
                  then
                    Command.Args.S
                      [ Command.Args.A "-o"
                      ; Command.Args.Target (Artifact.odoc_file ctx artifact)
                      ]
                  else
                    Command.Args.S
                      [ Command.Args.A "--output-dir"
                      ; Command.Args.A "_odoc"
                      ; Command.Args.A "--parent-id"
                      ; Command.Args.A parent
                      ])
               ; Command.Args.A "--enable-missing-root-warning"
               ; (match Artifact.get_kind artifact with
                  | Module (_, Lib (pkg, _)) ->
                    Command.Args.As [ "--warnings-tag"; Package.Name.to_string pkg ]
                  | Module (_, Private_lib _) ->
                    Command.Args.As [ "--warnings-tag"; "__private_lib__" ]
                  | Page (_, Pkg pkg) ->
                    Command.Args.As [ "--warnings-tag"; Package.Name.to_string pkg ]
                  | Page (_, Toplevel _) -> Command.Args.S []
                  | Asset _ -> Command.Args.S [])
               ; Dyn
                   (Action_builder.map cli_flags.compile ~f:(fun flags ->
                      Command.Args.As flags))
               ; Command.Args.Dep source_file
               ])
    in
    add_rule sctx run_odoc
;;

let link_odoc_rules sctx (odoc_file : Artifact.t) ~requires =
  let ctx = Super_context.context sctx in
  let pkg = Artifact.pkg odoc_file in
  let* extra_packages = Artifact.extra_packages odoc_file in
  let all_pkgs = Option.to_list pkg @ extra_packages in
  let deps = Dep.deps ctx all_pkgs requires in
  let* stdlib_opt = stdlib_lib (Context.name ctx) in
  let* pkg_discovery = Package_discovery.create ~context:ctx in
  let* workspace_pkgs = get_workspace_packages () in
  let all_pkg_names = List.map workspace_pkgs ~f:Package.Name.to_string in
  let warnings_tags_args =
    Command.Args.S
      (List.concat_map ("__private_lib__" :: all_pkg_names) ~f:(fun pkg_name ->
         [ Command.Args.A "--warnings-tags"; Command.Args.A pkg_name ]))
  in
  (* Suppress output for installed packages and vendored libraries *)
  let* quiet = Artifact.should_suppress_output odoc_file in
  let* cli_flags = cli_flags_env ~dir:(Context.build_dir ctx) in
  let artifact_config =
    { Odoc_config.deps = { packages = extra_packages; libraries = [] } }
  in
  let run_odoc =
    run_odoc
      sctx
      "link"
      ~quiet
      ~flags_for:(Some (Artifact.odoc_file ctx odoc_file))
      [ odoc_lib_flags ctx ~stdlib_opt requires pkg_discovery
      ; odoc_pkg_flags ctx pkg_discovery ~current_pkg_opt:pkg ~artifact_config ~requires
      ; (match pkg with
         | Some pkg_name ->
           Command.Args.As [ "--current-package"; Package.Name.to_string pkg_name ]
         | None -> Command.Args.S [])
      ; A "--enable-missing-root-warning"
      ; warnings_tags_args
      ; A "-o"
      ; Target (Artifact.odocl_file ctx odoc_file)
      ; Dyn (Action_builder.map cli_flags.link ~f:(fun flags -> Command.Args.As flags))
      ; Dep (Path.build (Artifact.odoc_file ctx odoc_file))
      ]
  in
  add_rule
    sctx
    (let open Action_builder.With_targets.O in
     Action_builder.with_no_targets deps >>> run_odoc)
;;

let generate_asset_artifact sctx ~artifact ~mode format =
  let ctx = Super_context.context sctx in
  match (format : Output_format.t) with
  | Markdown -> Memo.return ()
  | Json ->
    let source_file = Artifact.source_file artifact in
    let output_file = Artifact.output_file ctx mode Json artifact in
    add_rule sctx (Action_builder.copy ~src:source_file ~dst:output_file)
  | Html ->
    let html_root = Paths.output_root ctx mode Html in
    let doc_root = Paths.root ctx in
    let html_root_rel = Path.reach (Path.build html_root) ~from:(Path.build doc_root) in
    let source_file = Artifact.source_file artifact in
    let odocl_file = Artifact.odocl_file ctx artifact in
    let output_file = Artifact.output_file ctx mode Html artifact in
    let run_odoc =
      run_odoc
        sctx
        "html-generate-asset"
        ~quiet:false
        ~flags_for:None
        [ Command.Args.A "-o"
        ; Command.Args.A html_root_rel
        ; Command.Args.A "--asset-unit"
        ; Command.Args.Dep (Path.build odocl_file)
        ; Command.Args.Dep source_file
        ]
    in
    add_rule sctx (Action_builder.With_targets.add ~file_targets:[ output_file ] run_odoc)
;;

let odoc_support_path ctx ~mode ~flags ~pkg_name =
  match flags.Flags.support, pkg_name with
  | Flags.Per_package, Some pkg -> Paths.odoc_support_for_pkg ctx mode pkg
  | Flags.Root, _ | Flags.Per_package, None -> Paths.odoc_support ctx mode
;;

let odoc_support_uri ~html_root support_path =
  Path.reach (Path.build support_path) ~from:(Path.build html_root)
;;

let generate_output_action
      sctx
      ~artifact
      ?search_db
      ~sidebar_file
      ?(remap_file : Path.Build.t option = None)
      ~mode
      ~output_format
      ?pkg_name
      ()
  =
  let ctx = Super_context.context sctx in
  let doc_root = Paths.root ctx in
  let output_root = Paths.output_root ctx mode output_format in
  let output_root_rel = Path.reach (Path.build output_root) ~from:(Path.build doc_root) in
  let* cli_flags = cli_flags_env ~dir:(Context.build_dir ctx) in
  let cli_html_args =
    Command.Args.Dyn
      (Action_builder.map cli_flags.html ~f:(fun flags -> Command.Args.As flags))
  in
  let* subcommand, html_args =
    match (output_format : Output_format.t) with
    | Markdown -> Memo.return ("markdown-generate", Command.Args.empty)
    | Html | Json ->
      let html_root = Paths.output_root ctx mode Html in
      let* flags = Flags.get_memo ~dir:(Context.build_dir ctx) in
      let odoc_support_path = odoc_support_path ctx ~mode ~flags ~pkg_name in
      let odoc_support_uri = odoc_support_uri ~html_root odoc_support_path in
      (* sherlodoc.js lives in the per-package HTML dir when configured *)
      let sherlodoc_js_dir =
        match flags.support, pkg_name with
        | Flags.Per_package, Some pkg -> html_root ++ pkg
        | Flags.Root, _ | Flags.Per_package, None -> html_root
      in
      let search_args =
        match search_db with
        | Some search_db ->
          Sherlodoc.odoc_args
            sctx
            ~search_db
            ~dir_sherlodoc_dot_js:sherlodoc_js_dir
            ~html_root
        | None -> Command.Args.empty
      in
      let args =
        Command.Args.S
          [ Hidden_deps (Dune_engine.Dep.Set.of_files [ Path.build odoc_support_path ])
          ; search_args
          ; A "--support-uri"
          ; A odoc_support_uri
          ; A "--theme-uri"
          ; A odoc_support_uri
          ; (match remap_file with
             | None -> S []
             | Some rf -> S [ A "--remap-file"; Dep (Path.build rf) ])
          ; (match sidebar_file with
             | Some sf -> S [ A "--sidebar"; Dep (Path.build sf) ]
             | None -> S [])
          ; Output_format.args output_format
          ]
      in
      Memo.return ("html-generate", args)
  in
  let+ quiet = Artifact.should_suppress_output artifact in
  let odocl_dep = Command.Args.Dep (Path.build (Artifact.odocl_file ctx artifact)) in
  run_odoc
    sctx
    subcommand
    ~quiet
    ~flags_for:None
    [ A "-o"; A output_root_rel; cli_html_args; odocl_dep; html_args ]
;;

let generate_html_artifact
      sctx
      ~artifact
      ?search_db
      ~sidebar_file
      ?(remap_file : Path.Build.t option)
      ?(mode = Doc_mode.Local_only)
      ~output_format
      ?pkg_name
      ()
  =
  let ctx = Super_context.context sctx in
  match Artifact.get_kind artifact with
  | Asset _ -> generate_asset_artifact sctx ~artifact ~mode output_format
  | Module _ | Page _ ->
    let* action =
      generate_output_action
        sctx
        ~artifact
        ?search_db
        ~sidebar_file
        ~remap_file
        ~mode
        ~output_format
        ?pkg_name
        ()
    in
    let rule =
      let file_target () =
        Action_builder.With_targets.add
          ~file_targets:[ Artifact.output_file ctx mode output_format artifact ]
          action
      in
      match (output_format : Output_format.t) with
      | Markdown -> file_target ()
      | Html | Json ->
        (match Artifact.output_dir_target ctx mode output_format artifact with
         | Some dir ->
           Action_builder.With_targets.add_directories ~directory_targets:[ dir ] action
         | None -> file_target ())
    in
    add_rule sctx rule
;;

(* Run [odoc support-files -o <dir>] producing the CSS/JS/HTML assets in
   [dir], registered as a directory target. *)
let setup_support_files_rule sctx ~dir =
  let cmd =
    run_odoc
      sctx
      "support-files"
      ~quiet:false
      ~flags_for:None
      [ A "-o"; Path (Path.build dir) ]
  in
  add_rule
    sctx
    (Action_builder.With_targets.add_directories ~directory_targets:[ dir ] cmd)
;;

let setup_css_rule sctx ~mode =
  let ctx = Super_context.context sctx in
  setup_support_files_rule sctx ~dir:(Paths.odoc_support ctx mode)
;;

let setup_pkg_support_rule sctx ~mode ~pkg_name =
  let ctx = Super_context.context sctx in
  let pkg_html_dir = Paths.output_root ctx mode Html ++ pkg_name in
  setup_support_files_rule sctx ~dir:(Paths.odoc_support_for_pkg ctx mode pkg_name)
  >>> Sherlodoc.sherlodoc_dot_js sctx ~dir:pkg_html_dir
;;

(* Compute requires for linking an artifact.
   - Modules in a library: the library's transitive closure plus sibling libs
     in the same package (allowing cross-references between siblings).
   - Private libraries (no package): just the library's transitive closure.
   - Pages/assets in a package: libs in the package plus their transitive deps.
   Extra libs resolved from odoc-config.sexp are appended, then the whole list
   is deduplicated. *)
let compute_link_requires sctx ~artifact =
  let ctx = Super_context.context sctx in
  let closure libs = Lib.closure libs ~linking:false ~for_:Compilation_mode.Ocaml in
  let* base_requires =
    match Artifact.get_kind artifact with
    | Asset (_, (Pkg _ | Toplevel _)) -> Memo.return (Resolve.return [])
    | Module (_, Lib (pkg, lib)) ->
      let* closure = closure [ lib ] in
      let+ pkg_libs = Odoc_discovery.libs_of_pkg ctx ~pkg in
      Resolve.map closure ~f:(fun closure_libs -> (lib :: closure_libs) @ pkg_libs)
    | Module (_, Private_lib (_, lib)) ->
      let+ closure = closure [ lib ] in
      Resolve.map closure ~f:(fun libs -> lib :: libs)
    | Page ({ pkg_libs; _ }, (Pkg _ | Toplevel _)) ->
      if List.is_empty pkg_libs
      then Memo.return (Resolve.return [])
      else
        let+ closure = closure pkg_libs in
        Resolve.map closure ~f:(fun closure_libs -> pkg_libs @ closure_libs)
  in
  let+ extra_libs = Artifact.extra_libs artifact in
  Resolve.map base_requires ~f:(fun libs ->
    libs @ extra_libs |> Lib.Set.of_list |> Lib.Set.to_list)
;;

let link_artifact sctx ~artifact =
  let* requires = compute_link_requires sctx ~artifact in
  link_odoc_rules sctx artifact ~requires
;;

let setup_toplevel_index_artifact sctx ~mode =
  let ctx = Super_context.context sctx in
  let* artifact = Odoc_discovery.toplevel_index_artifact ctx ~mode in
  let* () =
    match Artifact.generated_content artifact with
    | Some content ->
      let output_path = Artifact.source_file artifact in
      add_rule
        sctx
        (Action_builder.write_file (Path.as_in_build_dir_exn output_path) content)
    | None -> Memo.return ()
  in
  let* () =
    compile_artifact
      sctx
      ~artifact
      ~lib_artifacts_by_module:Module_name.Map.empty
      ~package_lib_names:Lib_name.Set.empty
  in
  link_artifact sctx ~artifact
;;

(* Generate global search database from all visible odocl files *)
let generate_global_search_db sctx ~mode =
  let ctx = Super_context.context sctx in
  let* _real_pkgs, all_odocl_files =
    Odoc_discovery.collect_all_visible_odocls sctx ~mode ()
  in
  let dir = Paths.output_root ctx mode Html in
  Sherlodoc.search_db sctx ~dir ~external_odocls:[] all_odocl_files
;;

(* Generate the toplevel index artifact in the given format.
   HTML has extra machinery for search_db + sidebar_file; JSON/Markdown just
   go through the common single-artifact entry. *)
let setup_toplevel_index sctx mode format =
  let ctx = Super_context.context sctx in
  let* artifact = Odoc_discovery.toplevel_index_artifact ctx ~mode in
  match (format : Output_format.t) with
  | Markdown ->
    generate_html_artifact
      sctx
      ~artifact
      ~sidebar_file:None
      ~mode
      ~output_format:Markdown
      ()
  | Json ->
    generate_html_artifact sctx ~artifact ~sidebar_file:None ~mode ~output_format:Json ()
  | Html ->
    let* flags = Flags.get_memo ~dir:(Context.build_dir ctx) in
    let use_global =
      match flags.sidebar with
      | Flags.Global -> true
      | Flags.Per_package -> false
    in
    (* Create search_db and sidebar only for global mode.
       Skip search db entirely for Local_only to avoid expensive sherlodoc generation. *)
    let* search_db =
      match mode with
      | Doc_mode.Local_only -> Memo.return None
      | Doc_mode.Full ->
        if use_global
        then
          let+ db = generate_global_search_db sctx ~mode in
          Some db
        else Memo.return None
    in
    let sidebar_file =
      if use_global then Some (Paths.sidebar_file ctx mode Paths.Global) else None
    in
    generate_html_artifact
      sctx
      ~artifact
      ?search_db
      ~sidebar_file
      ~mode
      ~output_format:Html
      ()
;;

let setup_toplevel_index_deps sctx mode output =
  let ctx = Super_context.context sctx in
  let root = Paths.output_root ctx mode output in
  let alias_of_dir dir = Output_format.alias output ~mode ~dir in
  let* items = Odoc_discovery.Toplevel_index.get_items ~mode ctx in
  let deps =
    Dune_engine.Dep.Set.of_list_map items ~f:(fun item ->
      let name =
        match item with
        | Odoc_discovery.Toplevel_index.Package { name; _ } -> name
        | Odoc_discovery.Toplevel_index.Private_lib { unique_name; _ } -> unique_name
      in
      Dune_engine.Dep.alias (alias_of_dir (root ++ name)))
  in
  Rules.Produce.Alias.add_deps (alias_of_dir root) (Action_builder.deps deps)
;;

let lib_dir_path ctx ~output ~scope_id ~lib_name =
  let subdir =
    match output with
    | Odoc -> "_odoc"
    | Odocls -> "_odocls"
  in
  let base = Paths.root ctx ++ subdir in
  match scope_id with
  | Scope_id.Private_lib _ ->
    (* Private library: unique_name already identifies the library *)
    base ++ Scope_id.to_string scope_id
  | Scope_id.Package pkg ->
    (* Package library: path is pkg/lib *)
    base ++ Package.Name.to_string pkg ++ Lib_name.to_string lib_name
;;

let generate_index sctx ~mode ~scope ~packages ~odocl_files =
  let ctx = Super_context.context sctx in
  let index_file = Paths.index_file ctx mode scope in
  let open Command.Args in
  let odocl_file_args =
    List.map odocl_files ~f:(fun odocl_file -> Dep (Path.build odocl_file))
  in
  let action =
    let open Action_builder.With_targets.O in
    Action_builder.with_no_targets
      (Action_builder.all_unit
         (List.map packages ~f:(fun pkg ->
            let odocl_dir = Paths.odocl ctx (Pkg pkg) in
            let pkg_alias = Dep.odoc_all_alias ~dir:odocl_dir in
            Action_builder.dep (Dune_engine.Dep.alias pkg_alias))))
    >>> run_odoc
          sctx
          "compile-index"
          ~quiet:false
          ~flags_for:None
          ([ A "-o"; Target index_file ] @ odocl_file_args)
  in
  let* () = add_rule sctx action in
  Memo.return index_file
;;

type sidebar_variant =
  | Binary
  | Json of Output_format.t

let generate_sidebar sctx ~mode ~scope ~index_file variant =
  let ctx = Super_context.context sctx in
  let target, prepend_args =
    match variant with
    | Binary -> Paths.sidebar_file ctx mode scope, []
    | Json output_format ->
      Paths.sidebar_json ctx mode scope output_format, [ Command.Args.A "--json" ]
  in
  let sidebar_dir =
    match mode with
    | Doc_mode.Local_only -> "_sidebar"
    | Doc_mode.Full -> "_sidebar_full"
  in
  let index_relative_path =
    match scope with
    | Paths.Global -> sprintf "%s/index.odoc-index" sidebar_dir
    | Paths.Per_package pkg ->
      sprintf "%s/%s/index.odoc-index" sidebar_dir (Package.Name.to_string pkg)
  in
  let action =
    let open Action_builder.With_targets.O in
    Action_builder.with_no_targets (Action_builder.path (Path.build index_file))
    >>> run_odoc
          sctx
          "sidebar-generate"
          ~quiet:false
          ~flags_for:None
          (prepend_args @ [ Command.Args.A "-o"; Target target; A index_relative_path ])
  in
  add_rule sctx action
;;

let handle_sidebar_artifacts sctx ~mode pkg_or_lib_name =
  let ctx = Super_context.context sctx in
  let rules =
    Rules.collect_unit (fun () ->
      let pkg = Package.Name.of_string pkg_or_lib_name in
      let scope = Paths.Per_package pkg in
      let* all_artifacts, _lib_subdirs =
        Odoc_discovery.discover_package_artifacts
          sctx
          ctx
          ~pkg_or_lib_unique_name:pkg_or_lib_name
      in
      let odocl_files =
        List.filter_map all_artifacts ~f:(fun artifact ->
          if Artifact.hidden artifact
          then None
          else (
            match Artifact.get_kind artifact with
            | Asset _ -> None
            | Module _ | Page _ -> Some (Artifact.odocl_file ctx artifact)))
      in
      let* index_file = generate_index sctx ~mode ~scope ~packages:[ pkg ] ~odocl_files in
      generate_sidebar sctx ~mode ~scope ~index_file Binary)
  in
  Memo.return (Build_config.Gen_rules.make rules)
;;

let generate_global_sidebar sctx ~mode =
  let* real_pkgs, all_odocl_files =
    Odoc_discovery.collect_all_visible_odocls sctx ~mode ()
  in
  let* index_file =
    generate_index
      sctx
      ~mode
      ~scope:Paths.Global
      ~packages:real_pkgs
      ~odocl_files:all_odocl_files
  in
  generate_sidebar sctx ~mode ~scope:Paths.Global ~index_file Binary
;;

let handle_sidebar_root sctx ~dir ~mode =
  let ctx = Super_context.context sctx in
  let* flags = Flags.get_memo ~dir:(Context.build_dir ctx) in
  let* workspace_pkgs = get_workspace_packages () in
  let pkg_subdirs = List.map workspace_pkgs ~f:Package.Name.to_string in
  let* private_local_libs = Odoc_discovery.get_private_libraries ctx in
  let private_lib_subdirs =
    List.map private_local_libs ~f:(fun local_lib -> Odoc_scope.lib_unique_name local_lib)
  in
  let all_subdirs = pkg_subdirs @ private_lib_subdirs in
  let rules =
    match flags.sidebar with
    | Flags.Global -> Rules.collect_unit (fun () -> generate_global_sidebar sctx ~mode)
    | Flags.Per_package -> Memo.return Rules.empty
  in
  Memo.return
    (Build_config.Gen_rules.make
       ~build_dir_only_sub_dirs:
         (Build_config.Gen_rules.Build_only_sub_dirs.singleton
            ~dir
            (Subdir_set.of_list all_subdirs))
       rules)
;;

let handle_remap_artifacts sctx =
  let ctx = Super_context.context sctx in
  let rules =
    Rules.collect_unit (fun () ->
      let* pkg_discovery = Package_discovery.create ~context:ctx in
      let installed_packages =
        Package_discovery.all_installed_packages pkg_discovery |> Package.Name.Set.of_list
      in
      let* mappings =
        generate_remap_mappings_simple pkg_discovery ~packages:installed_packages
      in
      let remap_file = Paths.remap_file ctx in
      write_remap_file sctx ~remap_file ~mappings)
  in
  Memo.return (Build_config.Gen_rules.make rules)
;;

let generate_html_for_package
      sctx
      ~ctx
      ~scope_id
      ~all_artifacts
      ~dir
      ~mode
      ~output_format
      ()
  =
  let pkg = Scope_id.as_package_name scope_id in
  let pkg_name = Scope_id.to_string scope_id in
  let* flags = Flags.get_memo ~dir in
  let visible_artifacts =
    List.filter all_artifacts ~f:(fun a -> not (Artifact.hidden a))
  in
  let output_file a = Path.build (Artifact.output_file ctx mode output_format a) in
  let scope, should_generate_sidebar_json =
    match flags.sidebar with
    | Flags.Global -> Paths.Global, false
    | Flags.Per_package -> Paths.Per_package pkg, true
  in
  let index_file = Paths.index_file ctx mode scope in
  (* Generate sidebar.json when sidebar is per-package. *)
  let* () =
    if should_generate_sidebar_json
    then generate_sidebar sctx ~mode ~scope ~index_file (Json output_format)
    else Memo.return ()
  in
  (* [--sidebar]/remap/search-db are HTML-only (and the last two only in Full
     mode); for Json/Markdown they stay [None]. *)
  let sidebar_file =
    match output_format with
    | Html -> Some (Paths.sidebar_file ctx mode scope)
    | Json | Markdown -> None
  in
  let* search_db =
    match output_format, mode with
    | Json, _ | Markdown, _ | _, Doc_mode.Local_only -> Memo.return None
    | Html, Doc_mode.Full ->
      (match flags.sidebar with
       | Flags.Global ->
         let html_root = Paths.output_root ctx mode Html in
         Memo.return (Some (Path.Build.relative html_root "db.js"))
       | Flags.Per_package ->
         let odocls = List.map visible_artifacts ~f:(Artifact.odocl_file ctx) in
         let+ db = Sherlodoc.search_db sctx ~dir ~external_odocls:[] odocls in
         Some db)
  in
  let remap_file =
    match mode with
    | Doc_mode.Local_only -> Some (Paths.remap_file ctx)
    | Doc_mode.Full -> None
  in
  let* () =
    Memo.parallel_iter visible_artifacts ~f:(fun artifact ->
      generate_html_artifact
        sctx
        ~artifact
        ?search_db
        ~sidebar_file
        ?remap_file
        ~mode
        ~output_format
        ~pkg_name
        ())
  in
  let artifact_paths =
    List.filter_map visible_artifacts ~f:(fun artifact ->
      match output_format, Artifact.get_kind artifact with
      | Markdown, Asset _ -> None
      | _ -> Some (output_file artifact))
  in
  let all_paths =
    if should_generate_sidebar_json
    then Path.build (Paths.sidebar_json ctx mode scope output_format) :: artifact_paths
    else artifact_paths
  in
  let pkg_alias = Dep.format_alias output_format mode ctx (Pkg pkg) in
  let* () = Dep.add_file_deps pkg_alias all_paths in
  Memo.parallel_iter visible_artifacts ~f:(fun artifact ->
    match Artifact.get_kind artifact with
    | Module (_, ((Lib _ | Private_lib _) as target)) ->
      let lib_alias = Dep.format_alias output_format mode ctx target in
      Dep.add_file_deps lib_alias [ output_file artifact ]
    | Module _ | Page _ | Asset _ -> Memo.return ())
;;

let with_package_artifacts sctx ~dir ~pkg_or_lib_name ~f =
  let ctx = Super_context.context sctx in
  let* scope_id = Scope_id.of_string pkg_or_lib_name in
  let+ all_artifacts, lib_subdirs =
    Odoc_discovery.discover_package_artifacts
      sctx
      ctx
      ~pkg_or_lib_unique_name:pkg_or_lib_name
  in
  let all_lib_names =
    List.map lib_subdirs ~f:Lib_name.of_string |> Lib_name.Set.of_list
  in
  let rules = f ~ctx ~scope_id ~all_artifacts ~all_lib_names in
  Build_config.Gen_rules.make
    ~build_dir_only_sub_dirs:
      (Build_config.Gen_rules.Build_only_sub_dirs.singleton
         ~dir
         (Subdir_set.of_list lib_subdirs))
    rules
;;

let handle_odoc_artifacts sctx ~dir ~pkg_or_lib_name =
  Log.info (sprintf "handle_odoc_artifacts: %s" pkg_or_lib_name) [];
  with_package_artifacts
    sctx
    ~dir
    ~pkg_or_lib_name
    ~f:(fun ~ctx ~scope_id ~all_artifacts ~all_lib_names ->
      Log.info
        (sprintf
           "handle_odoc_artifacts(%s): %d artifacts, %d libs: %s"
           pkg_or_lib_name
           (List.length all_artifacts)
           (Lib_name.Set.cardinal all_lib_names)
           (Lib_name.Set.to_list all_lib_names
            |> List.map ~f:Lib_name.to_string
            |> String.concat ~sep:", "))
        [];
      Rules.collect_unit (fun () ->
        (* Build map from module name to odoc path once for all artifacts. *)
        let lib_artifacts_by_module =
          List.fold_left all_artifacts ~init:Module_name.Map.empty ~f:(fun acc artifact ->
            match Artifact.get_kind artifact with
            | Module ({ module_name; _ }, _) ->
              Module_name.Map.set
                acc
                module_name
                (Path.build (Artifact.odoc_file ctx artifact))
            | Page _ | Asset _ -> acc)
        in
        let* () =
          Memo.parallel_iter all_artifacts ~f:(fun artifact ->
            compile_artifact
              sctx
              ~artifact
              ~lib_artifacts_by_module
              ~package_lib_names:all_lib_names)
        in
        let* () =
          Memo.parallel_iter all_artifacts ~f:(fun artifact ->
            let odoc_file = Path.build (Artifact.odoc_file ctx artifact) in
            match Artifact.get_kind artifact with
            | Module (_, target) ->
              Dep.setup_deps ctx target (Path.Set.singleton odoc_file)
            | Page (_, target) | Asset (_, target) ->
              Dep.setup_deps ctx target (Path.Set.singleton odoc_file))
        in
        let lib_names_with_artifacts =
          List.filter_map all_artifacts ~f:(fun a ->
            Option.map (Artifact.lib a) ~f:Lib.name)
          |> Lib_name.Set.of_list
        in
        let* lib_alias_dirs =
          Lib_name.Set.to_list all_lib_names
          |> Memo.List.filter_map ~f:(fun lib_name ->
            if Lib_name.Set.mem lib_names_with_artifacts lib_name
            then Memo.return (Some (lib_dir_path ctx ~output:Odoc ~scope_id ~lib_name))
            else (
              let lib_dir = lib_dir_path ctx ~output:Odoc ~scope_id ~lib_name in
              let alias = Dep.odoc_all_alias ~dir:lib_dir in
              let+ () = Dep.add_file_deps alias [] in
              Some lib_dir))
        in
        match scope_id with
        | Scope_id.Private_lib _ -> Memo.return ()
        | Scope_id.Package pkg ->
          let pkg_dir = Paths.root ctx ++ "_odoc" ++ Package.Name.to_string pkg in
          let pkg_alias = Dep.odoc_all_alias ~dir:pkg_dir in
          Dep.add_odoc_all_deps pkg_alias ~dirs:lib_alias_dirs))
;;

let handle_odocl_artifacts sctx ~dir ~pkg_or_lib_name =
  with_package_artifacts
    sctx
    ~dir
    ~pkg_or_lib_name
    ~f:(fun ~ctx ~scope_id ~all_artifacts ~all_lib_names ->
      Rules.collect_unit (fun () ->
        let visible_artifacts =
          List.filter all_artifacts ~f:(fun a -> not (Artifact.hidden a))
        in
        let* () =
          Memo.parallel_iter visible_artifacts ~f:(fun artifact ->
            link_artifact sctx ~artifact)
        in
        let visible_lib_artifacts =
          List.filter visible_artifacts ~f:(fun a ->
            match Artifact.get_kind a with
            | Module _ -> true
            | Page _ | Asset _ -> false)
        in
        let* () =
          Memo.parallel_iter visible_lib_artifacts ~f:(fun artifact ->
            match Artifact.lib artifact with
            | Some lib ->
              let lib_name = Lib.name lib in
              let lib_dir = lib_dir_path ctx ~output:Odocls ~scope_id ~lib_name in
              let lib_alias = Dep.odoc_all_alias ~dir:lib_dir in
              let odocl_file = Path.build (Artifact.odocl_file ctx artifact) in
              Dep.add_file_deps lib_alias [ odocl_file ]
            | None -> Memo.return ())
        in
        let lib_names_with_artifacts =
          List.filter_map visible_lib_artifacts ~f:(fun a ->
            Option.map (Artifact.lib a) ~f:Lib.name)
          |> Lib_name.Set.of_list
        in
        let* () =
          Lib_name.Set.to_list all_lib_names
          |> Memo.parallel_iter ~f:(fun lib_name ->
            if Lib_name.Set.mem lib_names_with_artifacts lib_name
            then Memo.return ()
            else (
              let lib_dir = lib_dir_path ctx ~output:Odocls ~scope_id ~lib_name in
              let lib_alias = Dep.odoc_all_alias ~dir:lib_dir in
              Dep.add_file_deps lib_alias []))
        in
        match scope_id with
        | Scope_id.Private_lib _ -> Memo.return ()
        | Scope_id.Package pkg ->
          let pkg_dir = Paths.odocl_root ctx ++ Package.Name.to_string pkg in
          let pkg_alias = Dep.odoc_all_alias ~dir:pkg_dir in
          let all_odocl_paths =
            List.map visible_artifacts ~f:(fun a ->
              Path.build (Artifact.odocl_file ctx a))
          in
          Dep.add_file_deps pkg_alias all_odocl_paths))
;;

let handle_output_artifacts sctx ~dir ~mode ~pkg_or_lib_name ~output_format =
  let ctx = Super_context.context sctx in
  let* scope_id = Scope_id.of_string pkg_or_lib_name in
  let* flags = Flags.get_memo ~dir:(Context.build_dir ctx) in
  let* all_artifacts, lib_subdirs =
    Odoc_discovery.discover_package_artifacts
      sctx
      ctx
      ~pkg_or_lib_unique_name:pkg_or_lib_name
  in
  let all_lib_names =
    List.map lib_subdirs ~f:Lib_name.of_string |> Lib_name.Set.of_list
  in
  (* Check if we need per-package support files (HTML only) *)
  let needs_pkg_support =
    match flags.support, output_format with
    | Flags.Per_package, Output_format.Html -> true
    | _ -> false
  in
  (* Collect directory targets for module directories (deduplicated).
     Markdown has no directory targets: each artifact produces a primary .md
     file, so the library dir is populated by file-level rules. *)
  let module_dir_targets =
    match output_format with
    | Output_format.Markdown -> []
    | Output_format.Html | Output_format.Json ->
      List.filter_map all_artifacts ~f:(fun artifact ->
        if Artifact.hidden artifact
        then None
        else Artifact.output_dir_target ctx mode output_format artifact)
      |> Path.Build.Set.of_list
      |> Path.Build.Set.to_list
  in
  (* Add support directory target if per-package support is enabled *)
  let all_dir_targets =
    if needs_pkg_support
    then (
      let support_dir = Paths.odoc_support_for_pkg ctx mode pkg_or_lib_name in
      support_dir :: module_dir_targets)
    else module_dir_targets
  in
  let directory_targets =
    List.map all_dir_targets ~f:(fun dir -> dir, Loc.none) |> Path.Build.Map.of_list_exn
  in
  (* Note: we don't add odoc.support to subdirs - it's just a directory target,
     same as at the root level. Adding it to subdirs causes conflicts. *)
  let other_formats = List.filter Output_format.all ~f:(fun f -> f <> output_format) in
  let rules =
    Rules.collect_unit (fun () ->
      (if needs_pkg_support
       then setup_pkg_support_rule sctx ~mode ~pkg_name:pkg_or_lib_name
       else Memo.return ())
      >>> generate_html_for_package
            sctx
            ~ctx
            ~scope_id
            ~all_artifacts
            ~dir
            ~mode
            ~output_format
            ()
      >>> Memo.parallel_iter other_formats ~f:(fun other_format ->
        let other_alias = Output_format.alias other_format ~mode ~dir in
        Rules.Produce.Alias.add_deps other_alias (Action_builder.return ())
        >>>
        (* Add empty aliases for the other
             format in library subdirectories
             too *)
        Memo.parallel_iter (Lib_name.Set.to_list all_lib_names) ~f:(fun lib_name ->
          let lib_dir = dir ++ Lib_name.to_string lib_name in
          let lib_other_alias = Output_format.alias other_format ~mode ~dir:lib_dir in
          Rules.Produce.Alias.add_deps lib_other_alias (Action_builder.return ()))))
  in
  let build_dir_only_sub_dirs =
    match output_format with
    | Output_format.Markdown ->
      (* Markdown library dirs are directory targets, not subdirs *)
      Build_config.Gen_rules.Build_only_sub_dirs.empty
    | Output_format.Html | Output_format.Json ->
      Build_config.Gen_rules.Build_only_sub_dirs.singleton
        ~dir
        (Subdir_set.of_list lib_subdirs)
  in
  Memo.return
    (Build_config.Gen_rules.make ~build_dir_only_sub_dirs ~directory_targets rules)
;;

let setup_package_aliases_format
      sctx
      (pkg : Package.t)
      (output : Output_format.t)
      (mode : Doc_mode.t)
  =
  let ctx = Super_context.context sctx in
  let name = Package.name pkg in
  let alias =
    let pkg_dir = Package.dir pkg in
    let dir = Path.Build.append_source (Context.build_dir ctx) pkg_dir in
    Output_format.alias output ~mode ~dir
  in
  let deps_action =
    let open Action_builder.O in
    let* dep_set =
      Action_builder.of_memo
        (let open Memo.O in
         let* all_targets =
           match mode with
           | Doc_mode.Local_only ->
             (* For Local_only, just use workspace packages directly.
                No need to compute library closures - the actual file dependencies
                are handled by the compilation rules. *)
             let+ workspace_pkgs = get_workspace_packages () in
             let pkg_targets =
               List.map workspace_pkgs ~f:(fun p -> Target.Any (Target.Pkg p))
             in
             pkg_targets @ [ Target.Any (Target.Toplevel mode) ]
           | Doc_mode.Full ->
             (* For Full mode, expand to include all transitive dependencies *)
             let with_doc = Package_variable_name.with_doc in
             let doc_dep_packages =
               Package.depends pkg
               |> List.filter ~f:(Package_dependency.has_constraint_on with_doc)
               |> List.map ~f:(fun (dep : Package_dependency.t) -> dep.name)
             in
             let+ all_packages =
               Odoc_discovery.expand_packages_with_odoc_config
                 ctx
                 ~packages:(name :: doc_dep_packages)
                 ~private_libs:[]
             in
             let pkg_targets =
               Package.Name.Set.to_list all_packages
               |> List.map ~f:(fun p -> Target.Any (Target.Pkg p))
             in
             pkg_targets @ [ Target.Any (Target.Toplevel mode) ]
         in
         let unique_targets = List.sort_uniq all_targets ~compare:Target.compare_any in
         Memo.return
           (unique_targets
            |> List.map ~f:(fun (Target.Any t) -> Dep.format_alias output mode ctx t)
            |> Dune_engine.Dep.Set.of_list_map ~f:(fun f -> Dune_engine.Dep.alias f)))
    in
    let* dep_set_with_remap =
      match mode with
      | Doc_mode.Local_only ->
        (* Add remap file as dependency for Local_only mode *)
        let remap_file = Paths.remap_file ctx in
        let+ _ = Action_builder.path (Path.build remap_file) in
        dep_set
      | Doc_mode.Full -> Action_builder.return dep_set
    in
    Action_builder.deps dep_set_with_remap
  in
  Rules.Produce.Alias.add_deps alias deps_action
;;

let setup_package_aliases sctx (pkg : Package.t) =
  (* Set up aliases for both modes *)
  Memo.List.iter Doc_mode.all ~f:(fun mode ->
    Memo.parallel_iter Output_format.all ~f:(fun output ->
      setup_package_aliases_format sctx pkg output mode))
;;

let gen_project_rules sctx project =
  let* mask = Dune_load.mask () in
  (* Set up package aliases *)
  Dune_project.packages project
  |> Dune_lang.Package_name.Map.to_seq
  |> Memo.parallel_iter_seq ~f:(fun (_, (pkg : Package.t)) ->
    (* Check if this package is in the mask (honors -p flag) *)
    let should_build =
      Only_packages.mem_all mask || Only_packages.mem mask (Package.name pkg)
    in
    if should_build
    then
      (* setup @doc to build the correct html for the package *)
      setup_package_aliases sctx pkg
    else Memo.return ())
;;

let setup_private_library_doc_alias sctx ~scope ~dir (l : Library.t) =
  match l.visibility with
  | Public _ -> Memo.return ()
  | Private _ ->
    let* is_vendored = Source_tree.is_vendored (Path.Build.drop_build_context_exn dir) in
    if is_vendored
    then Memo.return ()
    else (
      let ctx = Super_context.context sctx in
      let* lib =
        let src_dir = Path.drop_optional_build_context_src_exn (Path.build dir) in
        Lib.DB.find_lib_id_even_when_hidden
          (Scope.libs scope)
          (Local (Library.to_lib_id ~src_dir l))
        >>| Option.value_exn
      in
      (* Create target for this private library and add its HTML to doc-private and doc-full.
       Dependencies are handled transitively through the odoc pipeline. *)
      let local_lib = Lib.Local.of_lib_exn lib in
      let lib_unique_name = Odoc_scope.lib_unique_name local_lib in
      let target = Target.Private_lib (lib_unique_name, lib) in
      let html_alias_local = Dep.format_alias Html Doc_mode.Local_only ctx target in
      let html_alias_full = Dep.format_alias Html Doc_mode.Full ctx target in
      let alias_dep alias =
        Action_builder.deps (Dune_engine.Dep.Set.singleton (Dune_engine.Dep.alias alias))
      in
      Rules.Produce.Alias.add_deps
        (Alias.make ~dir Alias0.private_doc)
        (alias_dep html_alias_local)
      >>> Rules.Produce.Alias.add_deps
            (Alias.make ~dir Alias0.doc_full)
            (alias_dep html_alias_full))
;;

let has_rules ?(directory_targets = Path.Build.Map.empty) f =
  let rules = Rules.collect_unit f in
  Memo.return (Gen_rules.make ~directory_targets rules)
;;

let handle_classify_dir sctx ~pkg_name ~lib_name =
  let pkg = Package.Name.of_string pkg_name in
  let lib_name = Lib_name.of_string lib_name in
  let ctx = Super_context.context sctx in
  let* pkg_libs = Odoc_discovery.libs_of_pkg ctx ~pkg in
  let* lib_opt =
    Memo.List.find_map pkg_libs ~f:(fun lib ->
      if Lib_name.equal (Lib.name lib) lib_name
      then Memo.return (Some lib)
      else Memo.return None)
  in
  match lib_opt with
  | None -> Memo.return ()
  | Some lib ->
    (match Lib.Local.of_lib lib with
     | Some _ -> Memo.return ()
     | None ->
       let info = Lib.info lib in
       let src_dir = Lib_info.src_dir info in
       let classify_output =
         Paths.root ctx
         ++ "classify"
         ++ pkg_name
         ++ Lib_name.to_string lib_name
         ++ "odoc.classify"
       in
       let run_classify =
         let program = odoc_program sctx (Context.build_dir ctx) in
         let deps = Action_builder.env_var "ODOC_SYNTAX" in
         let open Action_builder.With_targets.O in
         Action_builder.with_no_targets deps
         >>> Command.run_dyn_prog
               ~dir:(Path.build (Context.build_dir ctx))
               ~stdout_to:classify_output
               program
               [ A "classify"; A (Path.to_string src_dir) ]
       in
       add_rule sctx run_classify)
;;

let handle_mlds_dir sctx ~pkg_name =
  let ctx = Super_context.context sctx in
  let* all_artifacts, _lib_subdirs =
    Odoc_discovery.discover_package_artifacts sctx ctx ~pkg_or_lib_unique_name:pkg_name
  in
  Memo.List.iter all_artifacts ~f:(fun artifact ->
    match Artifact.generated_content artifact with
    | None -> Memo.return ()
    | Some content ->
      let output_path = Artifact.source_file artifact in
      add_rule
        sctx
        (Action_builder.write_file (Path.as_in_build_dir_exn output_path) content))
;;

let handle_output_root sctx ~mode ~output_format =
  let ctx = Super_context.context sctx in
  let directory_targets =
    match output_format with
    | Output_format.Html ->
      Path.Build.Map.singleton (Paths.odoc_support ctx mode) Loc.none
    | Output_format.Json | Output_format.Markdown -> Path.Build.Map.empty
  in
  let rules =
    Rules.collect_unit (fun () ->
      let* flags = Flags.get_memo ~dir:(Context.build_dir ctx) in
      (match output_format with
       | Output_format.Html ->
         Sherlodoc.sherlodoc_dot_js sctx ~dir:(Paths.output_root ctx mode Html)
         >>> setup_css_rule sctx ~mode
       | Output_format.Json | Output_format.Markdown -> Memo.return ())
      >>> setup_toplevel_index sctx mode output_format
      >>>
      let* artifact = Odoc_discovery.toplevel_index_artifact ctx ~mode in
      let output_file = Artifact.output_file ctx mode output_format artifact in
      let alias = Dep.format_alias output_format mode ctx (Toplevel mode) in
      Dep.add_file_deps alias [ Path.build output_file ]
      >>>
      (* Generate global sidebar JSON if
         configured *)
      (match flags.sidebar, output_format with
        | _, Output_format.Markdown -> Memo.return ()
        | Flags.Global, _ ->
          let index_file = Paths.index_file ctx mode Paths.Global in
          let sidebar_json = Paths.sidebar_json ctx mode Paths.Global output_format in
          generate_sidebar sctx ~mode ~scope:Paths.Global ~index_file (Json output_format)
          >>> Dep.add_file_deps alias [ Path.build sidebar_json ]
        | Flags.Per_package, _ -> Memo.return ())
      (* Add dependencies on all child
         directories so the alias builds
         everything *)
      >>> setup_toplevel_index_deps sctx mode output_format)
  in
  Memo.return (Build_config.Gen_rules.make ~directory_targets rules)
;;

let gen_rules sctx ~dir rest =
  let ctx = Super_context.context sctx in
  let redirect () = Memo.return (Gen_rules.redirect_to_parent Gen_rules.Rules.empty) in
  let empty_rules () =
    Memo.return (Build_config.Gen_rules.make (Memo.return Rules.empty))
  in
  let output_artifacts mode output_format pkg_or_lib_name =
    handle_output_artifacts sctx ~dir ~output_format ~mode ~pkg_or_lib_name
  in
  let handle_mlds_pkg pkg_name =
    let pkg = Package.Name.of_string pkg_name in
    let* all_libs = Odoc_discovery.libs_of_pkg ctx ~pkg in
    let lib_subdirs =
      List.map all_libs ~f:(fun lib -> Lib.name lib |> Lib_name.to_string)
    in
    let rules = Rules.collect_unit (fun () -> handle_mlds_dir sctx ~pkg_name) in
    Memo.return
      (Build_config.Gen_rules.make
         ~build_dir_only_sub_dirs:
           (Build_config.Gen_rules.Build_only_sub_dirs.singleton
              ~dir
              (Subdir_set.of_list lib_subdirs))
         rules)
  in
  let toplevel_index_rules mode =
    let rules = Rules.collect_unit (fun () -> setup_toplevel_index_artifact sctx ~mode) in
    Memo.return (Build_config.Gen_rules.make rules)
  in
  match rest with
  | [] ->
    Memo.return
      (Build_config.Gen_rules.make
         ~build_dir_only_sub_dirs:
           (Build_config.Gen_rules.Build_only_sub_dirs.singleton ~dir Subdir_set.all)
         (Memo.return Rules.empty))
  (* HTML/JSON/Markdown output trees *)
  | [ "_html" ] ->
    handle_output_root sctx ~mode:Doc_mode.Local_only ~output_format:Output_format.Html
  | [ "_html"; pkg_or_lib_name ] ->
    output_artifacts Doc_mode.Local_only Html pkg_or_lib_name
  | [ "_html_full" ] ->
    handle_output_root sctx ~mode:Doc_mode.Full ~output_format:Output_format.Html
  | [ "_html_full"; pkg_or_lib_name ] ->
    output_artifacts Doc_mode.Full Html pkg_or_lib_name
  | [ "_json" ] ->
    handle_output_root sctx ~mode:Doc_mode.Local_only ~output_format:Output_format.Json
  | [ "_json"; pkg_or_lib_name ] ->
    output_artifacts Doc_mode.Local_only Json pkg_or_lib_name
  | [ "_json_full" ] ->
    handle_output_root sctx ~mode:Doc_mode.Full ~output_format:Output_format.Json
  | [ "_json_full"; pkg_or_lib_name ] ->
    output_artifacts Doc_mode.Full Json pkg_or_lib_name
  | [ "_markdown" ] ->
    handle_output_root
      sctx
      ~mode:Doc_mode.Local_only
      ~output_format:Output_format.Markdown
  | [ "_markdown"; pkg_or_lib_name ] ->
    output_artifacts Doc_mode.Local_only Markdown pkg_or_lib_name
  | [ "_markdown_full" ] ->
    handle_output_root sctx ~mode:Doc_mode.Full ~output_format:Output_format.Markdown
  | [ "_markdown_full"; pkg_or_lib_name ] ->
    output_artifacts Doc_mode.Full Markdown pkg_or_lib_name
  | ("_html" | "_html_full" | "_json" | "_json_full" | "_markdown" | "_markdown_full")
    :: _
    :: _
    :: _ -> redirect ()
  (* Compiled/linked odoc trees *)
  | [ "_odoc" ] | [ "_odocls" ] | [ "_mlds" ] -> empty_rules ()
  | [ "_odoc"; pkg_or_lib_name ] -> handle_odoc_artifacts sctx ~dir ~pkg_or_lib_name
  | [ "_odocls"; pkg_or_lib_name ] -> handle_odocl_artifacts sctx ~dir ~pkg_or_lib_name
  | [ "_mlds"; pkg_name ] -> handle_mlds_pkg pkg_name
  | ("_odoc" | "_odocls" | "_mlds") :: _ :: _ :: _ -> redirect ()
  (* Toplevel index (mld + compile + link) *)
  | [ "_index" ] -> toplevel_index_rules Doc_mode.Local_only
  | [ "_index_full" ] -> toplevel_index_rules Doc_mode.Full
  (* Sidebars *)
  | [ "_sidebar" ] -> handle_sidebar_root sctx ~dir ~mode:Doc_mode.Local_only
  | [ "_sidebar"; pkg_or_lib_name ] ->
    handle_sidebar_artifacts sctx ~mode:Doc_mode.Local_only pkg_or_lib_name
  | [ "_sidebar_full" ] -> handle_sidebar_root sctx ~dir ~mode:Doc_mode.Full
  | [ "_sidebar_full"; pkg_or_lib_name ] ->
    handle_sidebar_artifacts sctx ~mode:Doc_mode.Full pkg_or_lib_name
  | ("_sidebar" | "_sidebar_full") :: _ :: _ :: _ -> redirect ()
  (* Remap file and sherlodoc search DB *)
  | [ "_remap" ] -> handle_remap_artifacts sctx
  | [ "_sherlodoc" ] ->
    let rules =
      Rules.collect_unit (fun () ->
        let* _real_pkgs, all_odocl_files =
          Odoc_discovery.collect_all_visible_odocls sctx ~mode:Doc_mode.Full ()
        in
        let dir = Paths.sherlodoc_root ctx in
        let+ _db =
          Sherlodoc.search_db_marshal sctx ~dir ~external_odocls:[] all_odocl_files
        in
        ())
    in
    Memo.return (Gen_rules.make rules)
  | [ "classify"; pkg_name; lib_name ] ->
    has_rules (fun () -> handle_classify_dir sctx ~pkg_name ~lib_name)
  | _ -> empty_rules ()
;;
