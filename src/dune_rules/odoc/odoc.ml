open Import
open Memo.O
module Gen_rules = Build_config.Gen_rules

let ( ++ ) = Path.Build.relative

module Target = Odoc_target
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
  let iter ~f = Memo.parallel_iter all ~f

  let args = function
    | Html -> Command.Args.empty
    | Json -> A "--as-json"
    | Markdown -> Command.Args.empty
  ;;

  let alias_name = function
    | Html -> Alias0.doc
    | Json -> Alias0.doc_json
    | Markdown -> Alias0.doc_markdown
  ;;

  let alias t ~dir = Alias.make (alias_name t) ~dir

  let toplevel_index_path format ctx =
    let base = Paths.output_root ctx format in
    match format with
    | Html -> base ++ "index.html"
    | Json -> base ++ "index.html.json"
    | Markdown -> base ++ "index.md"
  ;;
end

module Artifact = Odoc_artifact

module Dep : sig
  val odoc_all_alias : dir:Path.Build.t -> Alias.t

  (** [format_alias output ctx target] returns the alias that depends on all
      targets produced by odoc for [target] in output format [output]. *)
  val format_alias : Output_format.t -> Context.t -> 'a Target.t -> Alias.t

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

  let format_alias : type a. Output_format.t -> Context.t -> a Target.t -> Alias.t =
    fun f ctx m ->
    let dir = Paths.output ctx f m in
    Output_format.alias f ~dir
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

module Flags = struct
  type warnings = Dune_env.Odoc.warnings =
    | Fatal
    | Nonfatal

  type t = { warnings : warnings }

  let default = { warnings = Nonfatal }

  let get_memo ~dir =
    Env_stanza_db.value ~default ~dir ~f:(fun config ->
      let warnings = Option.value config.odoc.warnings ~default:default.warnings in
      Memo.return (Some { warnings }))
  ;;

  let get ~dir = get_memo ~dir |> Action_builder.of_memo
end

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
  | Page _ -> Memo.return (Action_builder.return ())
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
      | Page _ -> None
    in
    let dep_odoc_files =
      List.filter_map dep_modules ~f:(fun dep_module ->
        match current_module_name with
        | Some current when Module_name.equal current dep_module -> None
        | _ -> Module_name.Map.find lib_artifacts_by_module dep_module)
    in
    Dune_engine.Dep.Set.of_files dep_odoc_files |> Action_builder.deps
;;

let compile_artifact sctx ~artifact ~lib_artifacts_by_module ~package_lib_names =
  let ctx = Super_context.context sctx in
  match Artifact.get_kind artifact with
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
               ~quiet:false
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
                    Command.Args.As [ "--warnings-tag"; Package.Name.to_string pkg ])
               ; Command.Args.Dep source_file
               ])
    in
    add_rule sctx run_odoc
;;

let link_odoc_rules sctx (odoc_file : Artifact.t) ~requires =
  let ctx = Super_context.context sctx in
  let pkg = Artifact.pkg odoc_file in
  let deps = Dep.deps ctx (Option.to_list pkg) requires in
  let* pkg_discovery = Package_discovery.create ~context:ctx in
  let* include_flags = odoc_include_flags ctx pkg requires pkg_discovery in
  let* workspace_pkgs = get_workspace_packages () in
  let all_pkg_names = List.map workspace_pkgs ~f:Package.Name.to_string in
  let warnings_tags_args =
    Command.Args.S
      (List.concat_map ("__private_lib__" :: all_pkg_names) ~f:(fun pkg_name ->
         [ Command.Args.A "--warnings-tags"; Command.Args.A pkg_name ]))
  in
  let run_odoc =
    run_odoc
      sctx
      "link"
      ~quiet:false
      ~flags_for:(Some (Artifact.odoc_file ctx odoc_file))
      [ include_flags
      ; A "--enable-missing-root-warning"
      ; warnings_tags_args
      ; A "-o"
      ; Target (Artifact.odocl_file ctx odoc_file)
      ; Dep (Path.build (Artifact.odoc_file ctx odoc_file))
      ]
  in
  add_rule
    sctx
    (let open Action_builder.With_targets.O in
     Action_builder.with_no_targets deps >>> run_odoc)
;;

let generate_output_action sctx ~artifact ?search_db ~output_format () =
  let ctx = Super_context.context sctx in
  let doc_root = Paths.root ctx in
  let output_root = Paths.output_root ctx output_format in
  let output_root_rel = Path.reach (Path.build output_root) ~from:(Path.build doc_root) in
  let subcommand, html_args =
    match (output_format : Output_format.t) with
    | Markdown -> "markdown-generate", Command.Args.empty
    | Html | Json ->
      let html_root = Paths.output_root ctx Html in
      let odoc_support_path = Paths.odoc_support ctx in
      let odoc_support_uri =
        Path.reach (Path.build odoc_support_path) ~from:(Path.build html_root)
      in
      let search_args =
        match search_db with
        | Some search_db ->
          Sherlodoc.odoc_args sctx ~search_db ~dir_sherlodoc_dot_js:html_root ~html_root
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
          ; Output_format.args output_format
          ]
      in
      "html-generate", args
  in
  let odocl_dep = Command.Args.Dep (Path.build (Artifact.odocl_file ctx artifact)) in
  run_odoc
    sctx
    subcommand
    ~quiet:false
    ~flags_for:None
    [ A "-o"; A output_root_rel; odocl_dep; html_args ]
;;

let generate_html_artifact sctx ~artifact ?search_db ~output_format () =
  let ctx = Super_context.context sctx in
  match Artifact.get_kind artifact with
  | Module _ | Page _ ->
    let action = generate_output_action sctx ~artifact ?search_db ~output_format () in
    let rule =
      let file_target () =
        Action_builder.With_targets.add
          ~file_targets:[ Artifact.output_file ctx output_format artifact ]
          action
      in
      match (output_format : Output_format.t) with
      | Markdown -> file_target ()
      | Html | Json ->
        (match Artifact.output_dir_target ctx output_format artifact with
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

let setup_css_rule sctx =
  let ctx = Super_context.context sctx in
  setup_support_files_rule sctx ~dir:(Paths.odoc_support ctx)
;;

(* Compute requires for linking an artifact.
   - Modules in a library: the library's transitive closure plus sibling libs
     in the same package (allowing cross-references between siblings).
   - Private libraries (no package): just the library's transitive closure.
   - Pages in a package: libs in the package plus their transitive deps. *)
let compute_link_requires sctx ~artifact =
  let ctx = Super_context.context sctx in
  let closure libs = Lib.closure libs ~linking:false ~for_:Compilation_mode.Ocaml in
  match Artifact.get_kind artifact with
  | Module (_, Lib (pkg, lib)) ->
    let* closure = closure [ lib ] in
    let+ pkg_libs = Odoc_discovery.libs_of_pkg ctx ~pkg in
    Resolve.map closure ~f:(fun closure_libs -> (lib :: closure_libs) @ pkg_libs)
  | Module (_, Private_lib (_, lib)) ->
    let+ closure = closure [ lib ] in
    Resolve.map closure ~f:(fun libs -> lib :: libs)
  | Page ({ pkg_libs; _ }, Pkg _) ->
    if List.is_empty pkg_libs
    then Memo.return (Resolve.return [])
    else
      let+ closure = closure pkg_libs in
      Resolve.map closure ~f:(fun closure_libs -> pkg_libs @ closure_libs)
;;

let link_artifact sctx ~artifact =
  let* requires = compute_link_requires sctx ~artifact in
  link_odoc_rules sctx artifact ~requires
;;

let sp = Printf.sprintf

module Toplevel_index = struct
  type item =
    { name : string
    ; version : Package_version.t option
    ; link : string
    }

  let of_packages packages output_format =
    Package.Name.Map.to_list_map packages ~f:(fun name package ->
      let name = Package.Name.to_string name in
      let extension =
        match (output_format : Output_format.t) with
        | Markdown -> "md"
        | Html | Json -> "html"
      in
      { name; version = Package.version package; link = sp "%s/index.%s" name extension })
  ;;

  let html_list_items t =
    List.map t ~f:(fun { name; version; link } ->
      let link = sp {|<a href="%s">%s</a>|} link name in
      let version_suffix =
        match version with
        | None -> ""
        | Some v -> sp {| <span class="version">%s</span>|} (Package_version.to_string v)
      in
      sp "<li>%s%s</li>" link version_suffix)
    |> String.concat ~sep:"\n      "
  ;;

  let html t =
    sp
      {|<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>index</title>
    <link rel="stylesheet" href="./%s/odoc.css"/>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  </head>
  <body>
    <main class="content">
      <div class="by-name">
      <h2>OCaml package documentation</h2>
      <ol>
      %s
      </ol>
      </div>
    </main>
  </body>
</html>|}
      Paths.odoc_support_dirname
      (html_list_items t)
  ;;

  let string_to_json s = `String s
  let list_to_json ~f l = `List (List.map ~f l)

  let option_to_json ~f = function
    | None -> `Null
    | Some x -> f x
  ;;

  let item_to_json { name; version; link } =
    `Assoc
      [ "name", string_to_json name
      ; ( "version"
        , Option.map ~f:Package_version.to_string version
          |> option_to_json ~f:string_to_json )
      ; "link", string_to_json link
      ]
  ;;

  (** This format is public API. *)
  let to_json items = `Assoc [ "packages", list_to_json items ~f:item_to_json ]

  let json t = Json.to_string (to_json t)

  let markdown t =
    let b = Buffer.create 256 in
    Buffer.add_string b "# OCaml Package Documentation\n\n";
    List.iter t ~f:(fun { name; version; link } ->
      Buffer.add_string b (sp "- [%s](%s)" name link);
      (match version with
       | None -> ()
       | Some v -> Buffer.add_string b (sp " (version %s)" (Package_version.to_string v)));
      Buffer.add_char b '\n');
    Buffer.contents b
  ;;

  let content (output : Output_format.t) t =
    match output with
    | Html -> html t
    | Json -> json t
    | Markdown -> markdown t
  ;;
end

let setup_toplevel_index_rule sctx output =
  let* packages = Dune_load.packages () in
  let index = Toplevel_index.of_packages packages output in
  let content = Toplevel_index.content output index in
  let ctx = Super_context.context sctx in
  let path = Output_format.toplevel_index_path output ctx in
  add_rule sctx (Action_builder.write_file path content)
;;

let setup_toplevel_index_deps sctx output =
  let ctx = Super_context.context sctx in
  let root = Paths.output_root ctx output in
  let alias_of_dir dir = Output_format.alias output ~dir in
  let* packages = Dune_load.packages () in
  let deps =
    Package.Name.Map.foldi packages ~init:Dune_engine.Dep.Set.empty ~f:(fun name _ acc ->
      let pkg_dir = root ++ Package.Name.to_string name in
      Dune_engine.Dep.Set.add acc (Dune_engine.Dep.alias (alias_of_dir pkg_dir)))
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

let generate_html_for_package sctx ~ctx ~scope_id ~all_artifacts ~output_format () =
  let pkg = Scope_id.as_package_name scope_id in
  let visible_artifacts =
    List.filter all_artifacts ~f:(fun a -> not (Artifact.hidden a))
  in
  let output_file a = Path.build (Artifact.output_file ctx output_format a) in
  let* () =
    Memo.parallel_iter visible_artifacts ~f:(fun artifact ->
      generate_html_artifact sctx ~artifact ~output_format ())
  in
  let artifact_paths = List.map visible_artifacts ~f:output_file in
  let pkg_alias = Dep.format_alias output_format ctx (Pkg pkg) in
  let* () = Dep.add_file_deps pkg_alias artifact_paths in
  Memo.parallel_iter visible_artifacts ~f:(fun artifact ->
    match Artifact.get_kind artifact with
    | Module (_, ((Lib _ | Private_lib _) as target)) ->
      let lib_alias = Dep.format_alias output_format ctx target in
      Dep.add_file_deps lib_alias [ output_file artifact ]
    | Module _ | Page _ -> Memo.return ())
;;

let default_index ~pkg ~lib_artifacts =
  let b = Buffer.create 512 in
  Printf.bprintf b "{0 %s index}\n" (Package.Name.to_string pkg);
  List.sort lib_artifacts ~compare:(fun (x, _) (y, _) ->
    Lib_name.compare (Lib.name x) (Lib.name y))
  |> List.iter ~f:(fun (lib, artifacts) ->
    let modules =
      List.filter_map artifacts ~f:(fun artifact ->
        if Odoc_artifact.hidden artifact
        then None
        else (
          match Odoc_artifact.get_kind artifact with
          | Module ({ visible = true; module_name; _ }, _) -> Some module_name
          | _ -> None))
    in
    Printf.bprintf b "{1 Library %s}\n" (Lib_name.to_string (Lib.name lib));
    Buffer.add_string
      b
      (match modules with
       | [ x ] ->
         Printf.sprintf
           "The entry point of this library is the module:\n{!module-%s}.\n"
           (Module_name.to_string x)
       | _ ->
         Printf.sprintf
           "This library exposes the following toplevel modules:\n{!modules:%s}\n"
           (modules
            |> List.sort ~compare:Module_name.compare
            |> List.map ~f:Module_name.to_string
            |> String.concat ~sep:" ")));
  Buffer.contents b
;;

let with_package_artifacts sctx ~dir ~pkg_or_lib_name ~f =
  let ctx = Super_context.context sctx in
  let* scope_id = Scope_id.of_string pkg_or_lib_name in
  let+ all_artifacts, lib_subdirs =
    Odoc_discovery.discover_package_artifacts
      sctx
      ctx
      ~default_index
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
            | Page _ -> acc)
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
            | Page (_, target) -> Dep.setup_deps ctx target (Path.Set.singleton odoc_file))
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
            | Page _ -> false)
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

let handle_output_artifacts sctx ~dir ~pkg_or_lib_name ~output_format =
  let ctx = Super_context.context sctx in
  let* scope_id = Scope_id.of_string pkg_or_lib_name in
  let* all_artifacts, lib_subdirs =
    Odoc_discovery.discover_package_artifacts
      sctx
      ctx
      ~default_index
      ~pkg_or_lib_unique_name:pkg_or_lib_name
  in
  let all_lib_names =
    List.map lib_subdirs ~f:Lib_name.of_string |> Lib_name.Set.of_list
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
        else Artifact.output_dir_target ctx output_format artifact)
      |> Path.Build.Set.of_list
      |> Path.Build.Set.to_list
  in
  let directory_targets =
    List.map module_dir_targets ~f:(fun dir -> dir, Loc.none)
    |> Path.Build.Map.of_list_exn
  in
  let other_formats = List.filter Output_format.all ~f:(fun f -> f <> output_format) in
  let rules =
    Rules.collect_unit (fun () ->
      generate_html_for_package sctx ~ctx ~scope_id ~all_artifacts ~output_format ()
      >>> Memo.parallel_iter other_formats ~f:(fun other_format ->
        let other_alias = Output_format.alias other_format ~dir in
        Rules.Produce.Alias.add_deps other_alias (Action_builder.return ())
        >>> Memo.parallel_iter (Lib_name.Set.to_list all_lib_names) ~f:(fun lib_name ->
          let lib_dir = dir ++ Lib_name.to_string lib_name in
          let lib_other_alias = Output_format.alias other_format ~dir:lib_dir in
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

let setup_package_aliases_format sctx (pkg : Package.t) (output : Output_format.t) =
  let ctx = Super_context.context sctx in
  let alias =
    let pkg_dir = Package.dir pkg in
    let dir = Path.Build.append_source (Context.build_dir ctx) pkg_dir in
    Output_format.alias output ~dir
  in
  let deps_action =
    let open Action_builder.O in
    let* dep_set =
      Action_builder.of_memo
        (let open Memo.O in
         let+ workspace_pkgs = get_workspace_packages () in
         let pkg_aliases =
           List.map workspace_pkgs ~f:(fun p ->
             Dep.format_alias output ctx (Target.Pkg p))
         in
         let toplevel_alias =
           Output_format.alias output ~dir:(Paths.output_root ctx output)
         in
         toplevel_alias :: pkg_aliases
         |> Dune_engine.Dep.Set.of_list_map ~f:Dune_engine.Dep.alias)
    in
    Action_builder.deps dep_set
  in
  Rules.Produce.Alias.add_deps alias deps_action
;;

let setup_package_aliases sctx (pkg : Package.t) =
  Output_format.iter ~f:(setup_package_aliases_format sctx pkg)
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
      (* Create target for this private library and add its HTML to doc-private.
         Dependencies are handled transitively through the odoc pipeline. *)
      let local_lib = Lib.Local.of_lib_exn lib in
      let lib_unique_name = Odoc_scope.lib_unique_name local_lib in
      let target = Target.Private_lib (lib_unique_name, lib) in
      let html_alias = Dep.format_alias Html ctx target in
      Rules.Produce.Alias.add_deps
        (Alias.make ~dir Alias0.private_doc)
        (Action_builder.deps
           (Dune_engine.Dep.Set.singleton (Dune_engine.Dep.alias html_alias))))
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
    Odoc_discovery.discover_package_artifacts
      sctx
      ctx
      ~default_index
      ~pkg_or_lib_unique_name:pkg_name
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

let handle_output_root sctx ~output_format =
  let ctx = Super_context.context sctx in
  let directory_targets =
    match output_format with
    | Output_format.Html -> Path.Build.Map.singleton (Paths.odoc_support ctx) Loc.none
    | Output_format.Json | Output_format.Markdown -> Path.Build.Map.empty
  in
  let rules =
    Rules.collect_unit (fun () ->
      (match output_format with
       | Output_format.Html ->
         Sherlodoc.sherlodoc_dot_js sctx ~dir:(Paths.output_root ctx Html)
         >>> setup_css_rule sctx
       | Output_format.Json | Output_format.Markdown -> Memo.return ())
      >>> setup_toplevel_index_rule sctx output_format
      >>>
      (* Add dependencies on all child directories so the alias builds
         everything. *)
      let alias =
        Output_format.alias output_format ~dir:(Paths.output_root ctx output_format)
      in
      let toplevel_path = Output_format.toplevel_index_path output_format ctx in
      Dep.add_file_deps alias [ Path.build toplevel_path ]
      >>> setup_toplevel_index_deps sctx output_format)
  in
  Memo.return (Build_config.Gen_rules.make ~directory_targets rules)
;;

let gen_rules sctx ~dir rest =
  let ctx = Super_context.context sctx in
  let redirect () = Memo.return (Gen_rules.redirect_to_parent Gen_rules.Rules.empty) in
  let empty_rules () =
    Memo.return (Build_config.Gen_rules.make (Memo.return Rules.empty))
  in
  let output_artifacts output_format pkg_or_lib_name =
    handle_output_artifacts sctx ~dir ~output_format ~pkg_or_lib_name
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
  match rest with
  | [] ->
    Memo.return
      (Build_config.Gen_rules.make
         ~build_dir_only_sub_dirs:
           (Build_config.Gen_rules.Build_only_sub_dirs.singleton ~dir Subdir_set.all)
         (Memo.return Rules.empty))
  (* HTML/JSON/Markdown output trees *)
  | [ "_html" ] -> handle_output_root sctx ~output_format:Output_format.Html
  | [ "_html"; pkg_or_lib_name ] -> output_artifacts Html pkg_or_lib_name
  | [ "_json" ] -> handle_output_root sctx ~output_format:Output_format.Json
  | [ "_json"; pkg_or_lib_name ] -> output_artifacts Json pkg_or_lib_name
  | [ "_markdown" ] -> handle_output_root sctx ~output_format:Output_format.Markdown
  | [ "_markdown"; pkg_or_lib_name ] -> output_artifacts Markdown pkg_or_lib_name
  | ("_html" | "_json" | "_markdown") :: _ :: _ :: _ -> redirect ()
  (* Compiled/linked odoc trees *)
  | [ "_odoc" ] | [ "_odocls" ] | [ "_mlds" ] -> empty_rules ()
  | [ "_odoc"; pkg_or_lib_name ] -> handle_odoc_artifacts sctx ~dir ~pkg_or_lib_name
  | [ "_odocls"; pkg_or_lib_name ] -> handle_odocl_artifacts sctx ~dir ~pkg_or_lib_name
  | [ "_mlds"; pkg_name ] -> handle_mlds_pkg pkg_name
  | ("_odoc" | "_odocls" | "_mlds") :: _ :: _ :: _ -> redirect ()
  (* Sherlodoc search DB *)
  | [ "_sherlodoc" ] ->
    let rules =
      Rules.collect_unit (fun () ->
        let* _real_pkgs, all_odocl_files =
          Odoc_discovery.collect_all_visible_odocls sctx ~default_index ()
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
