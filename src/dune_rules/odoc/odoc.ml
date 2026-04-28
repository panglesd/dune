open Import
open Memo.O
module Gen_rules = Build_config.Gen_rules

let ( ++ ) = Path.Build.relative

let pkg_or_lnu (local_lib : Lib.Local.t) =
  let lib = Lib.Local.to_lib local_lib in
  match Lib_info.package (Lib.info lib) with
  | Some p -> Package.Name.to_string p
  | None -> Odoc_scope.lib_unique_name local_lib
;;

module Target = Odoc_target

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

  (** [deps ctx pkg libraries] returns all odoc dependencies of [libraries]. If
      [libraries] are all part of a package [pkg], then the odoc dependencies of
      the package are also returned*)
  val deps
    :  Context.t
    -> Package.Name.t option
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

  let deps ctx pkg requires =
    let open Action_builder.O in
    let* libs = Resolve.read requires in
    Action_builder.deps
      (let init =
         match pkg with
         | Some p ->
           Dep.Set.singleton (Dep.alias (odoc_all_alias ~dir:(Paths.odocs ctx (Pkg p))))
         | None -> Dep.Set.empty
       in
       List.fold_left libs ~init ~f:(fun acc (lib : Lib.t) ->
         match Lib.Local.of_lib lib with
         | None -> acc
         | Some lib ->
           let dir = Paths.odocs ctx (Target.Lib lib) in
           Dep.Set.add acc (Dep.alias (odoc_all_alias ~dir))))
  ;;

  let setup_deps : type a. Context.t -> a Target.t -> Path.Set.t -> unit Memo.t =
    fun ctx m files ->
    add_file_deps (odoc_all_alias_for_target ctx m) (Path.Set.to_list files)
  ;;
end

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
  let deps = Action_builder.env_var "ODOC_SYNTAX" in
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

let odoc_include_flags ctx pkg requires =
  Resolve.args
    (let open Resolve.O in
     let+ libs = requires in
     let paths =
       List.fold_left libs ~init:Path.Set.empty ~f:(fun paths lib ->
         match Lib.Local.of_lib lib with
         | None -> paths
         | Some lib -> Path.Set.add paths (Path.build (Paths.odocs ctx (Target.Lib lib))))
     in
     let paths =
       match pkg with
       | Some p -> Path.Set.add paths (Path.build (Paths.odocs ctx (Pkg p)))
       | None -> paths
     in
     Command.Args.S
       (List.concat_map (Path.Set.to_list paths) ~f:(fun dir ->
          [ Command.Args.A "-I"; Path dir ])))
;;

let compile_artifact sctx ~artifact ~module_deps ~requires =
  let ctx = Super_context.context sctx in
  let source_file = Artifact.source_file artifact in
  let include_flags, lib_deps, pkg_arg =
    match Artifact.get_kind artifact with
    | Module (_, Lib local_lib) ->
      let pkg = Lib_info.package (Lib.Local.info local_lib) in
      let self_dir = Path.build (Paths.odocs ctx (Target.Lib local_lib)) in
      let flags =
        Command.Args.S [ A "-I"; Path self_dir; odoc_include_flags ctx pkg requires ]
      in
      flags, Dep.deps ctx pkg requires, Command.Args.As [ "--pkg"; pkg_or_lnu local_lib ]
    | Page (_, Pkg pkg) ->
      ( Command.Args.empty
      , Action_builder.return ()
      , Command.Args.As [ "--pkg"; Package.Name.to_string pkg ] )
  in
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
             ; Command.Args.A "-o"
             ; Command.Args.Target (Artifact.odoc_file ctx artifact)
             ; pkg_arg
             ; Command.Args.Dep source_file
             ])
  in
  add_rule sctx run_odoc
;;

let link_odoc_rules sctx (odoc_file : Artifact.t) ~requires =
  let ctx = Super_context.context sctx in
  let pkg = Artifact.pkg odoc_file in
  let deps = Dep.deps ctx pkg requires in
  let include_flags = odoc_include_flags ctx pkg requires in
  let run_odoc =
    run_odoc
      sctx
      "link"
      ~quiet:false
      ~flags_for:(Some (Artifact.odoc_file ctx odoc_file))
      [ include_flags
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
          Sherlodoc.odoc_args sctx ~search_db ~dir_sherlodoc_dot_js:html_root
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
      Action_builder.With_targets.add
        ~file_targets:[ Artifact.output_file ctx output_format artifact ]
        action
    in
    add_rule sctx rule
;;

let setup_css_rule sctx =
  let ctx = Super_context.context sctx in
  let dir = Paths.odoc_support ctx in
  let run_odoc =
    let cmd =
      run_odoc
        sctx
        ~dir:(Context.build_dir ctx)
        "support-files"
        ~quiet:false
        ~flags_for:None
        [ A "-o"; Path (Path.build dir) ]
    in
    Action_builder.With_targets.add_directories ~directory_targets:[ dir ] cmd
  in
  add_rule sctx run_odoc
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

let libs_of_pkg ctx ~pkg =
  let+ { Scope.DB.Lib_entry.Set.libraries; _ } =
    Scope.DB.lib_entries_of_package ctx pkg
  in
  (* Filter out all implementations of virtual libraries *)
  List.filter_map libraries ~f:(fun lib ->
    match Lib.Local.to_lib lib |> Lib.info |> Lib_info.implements with
    | None -> Some lib
    | Some _ -> None)
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

let generate_html_for_package sctx ~ctx ~pkg ~search_db ~all_artifacts ~output_format () =
  let visible_artifacts =
    List.filter all_artifacts ~f:(fun a -> not (Artifact.hidden a))
  in
  let output_file a = Path.build (Artifact.output_file ctx output_format a) in
  let* () =
    Memo.parallel_iter visible_artifacts ~f:(fun artifact ->
      generate_html_artifact sctx ~artifact ?search_db ~output_format ())
  in
  let toplevel = Path.build (Output_format.toplevel_index_path output_format ctx) in
  let artifact_paths = toplevel :: List.map visible_artifacts ~f:output_file in
  let pkg_alias = Dep.format_alias output_format ctx (Pkg pkg) in
  let* () = Dep.add_file_deps pkg_alias artifact_paths in
  Memo.parallel_iter visible_artifacts ~f:(fun artifact ->
    match Artifact.get_kind artifact with
    | Module (_, (Lib _ as target)) ->
      let lib_alias = Dep.format_alias output_format ctx target in
      Dep.add_file_deps lib_alias [ toplevel; output_file artifact ]
    | Page _ -> Memo.return ())
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

let with_package_artifacts sctx ~pkg_or_lib_name ~f =
  let ctx = Super_context.context sctx in
  let+ all_artifacts, _lib_subdirs, _gen_index, pkg =
    Odoc_discovery.discover_package_artifacts
      sctx
      ctx
      ~default_index
      ~pkg_or_lib_unique_name:pkg_or_lib_name
  in
  let rules = f ~ctx ~pkg ~all_artifacts in
  Build_config.Gen_rules.make rules
;;

let page_artifacts =
  List.filter ~f:(fun a ->
    match Artifact.get_kind a with
    | Page _ -> true
    | Module _ -> false)
;;

let setup_library_odoc_rules cctx (local_lib : Lib.Local.t) =
  let sctx = Compilation_context.super_context cctx in
  let ctx = Super_context.context sctx in
  let obj_dir = Compilation_context.obj_dir cctx in
  let dep_graphs = Compilation_context.dep_graphs cctx in
  let modules = Compilation_context.modules cctx |> Modules.With_vlib.drop_vlib in
  let* requires = Compilation_context.requires_compile cctx in
  let module_deps_for m =
    Action_builder.dyn_paths_unit
      (let open Action_builder.O in
       let+ deps =
         if Module.has m ~ml_kind:Intf
         then Dep_graph.deps_of dep_graphs.intf m
         else Dep_graph.deps_of dep_graphs.impl m
       in
       List.map deps ~f:(fun m -> Path.build (Obj_dir.Module.odoc obj_dir m)))
  in
  let module_artifacts =
    Modules.fold modules ~init:[] ~f:(fun m acc ->
      (m, Odoc_discovery.module_artifact ~local_lib m) :: acc)
  in
  let* () =
    Memo.parallel_iter module_artifacts ~f:(fun (m, artifact) ->
      compile_artifact sctx ~artifact ~module_deps:(module_deps_for m) ~requires)
  in
  let odoc_files =
    Path.Set.of_list_map module_artifacts ~f:(fun (_, a) ->
      Path.build (Artifact.odoc_file ctx a))
  in
  Dep.setup_deps ctx (Lib local_lib) odoc_files
;;

let handle_odoc_pkg_pages sctx ~dir:_ ~pkg_name =
  let ctx = Super_context.context sctx in
  let rules =
    Rules.collect_unit (fun () ->
      let* all_artifacts, _lib_subdirs, _gen_index, _pkg =
        Odoc_discovery.discover_package_artifacts
          sctx
          ctx
          ~default_index
          ~pkg_or_lib_unique_name:pkg_name
      in
      let pages = page_artifacts all_artifacts in
      let* () =
        Memo.parallel_iter pages ~f:(fun artifact ->
          compile_artifact
            sctx
            ~artifact
            ~module_deps:(Action_builder.return ())
            ~requires:(Resolve.return []))
      in
      Memo.parallel_iter pages ~f:(fun artifact ->
        match Artifact.get_kind artifact with
        | Page (_, target) ->
          let odoc_file = Path.build (Artifact.odoc_file ctx artifact) in
          Dep.setup_deps ctx target (Path.Set.singleton odoc_file)
        | Module _ -> Memo.return ()))
  in
  Memo.return (Build_config.Gen_rules.make rules)
;;

let handle_odocl_artifacts sctx ~pkg_or_lib_name =
  with_package_artifacts sctx ~pkg_or_lib_name ~f:(fun ~ctx ~pkg ~all_artifacts ->
    Rules.collect_unit (fun () ->
      let visible_artifacts =
        List.filter all_artifacts ~f:(fun a -> not (Artifact.hidden a))
      in
      let libs =
        List.filter_map all_artifacts ~f:Artifact.lib
        |> List.sort_uniq ~compare:(fun a b -> Lib_name.compare (Lib.name a) (Lib.name b))
      in
      let* requires =
        if List.is_empty libs
        then Memo.return (Resolve.return [])
        else Lib.closure libs ~linking:false ~for_:Compilation_mode.Ocaml
      in
      let* () =
        Memo.parallel_iter visible_artifacts ~f:(fun artifact ->
          link_odoc_rules sctx artifact ~requires)
      in
      match pkg with
      | None -> Memo.return ()
      | Some pkg ->
        let pkg_dir = Paths.odocl_root ctx ++ Package.Name.to_string pkg in
        let pkg_alias = Dep.odoc_all_alias ~dir:pkg_dir in
        let all_odocl_paths =
          List.map visible_artifacts ~f:(fun a -> Path.build (Artifact.odocl_file ctx a))
        in
        Dep.add_file_deps pkg_alias all_odocl_paths))
;;

let handle_output_artifacts sctx ~dir ~pkg_or_lib_name ~output_formats =
  let ctx = Super_context.context sctx in
  let pkg = Package.Name.of_string pkg_or_lib_name in
  let* all_artifacts, lib_subdirs, _gen_index, _pkg =
    Odoc_discovery.discover_package_artifacts
      sctx
      ctx
      ~default_index
      ~pkg_or_lib_unique_name:pkg_or_lib_name
  in
  let all_lib_names =
    List.map lib_subdirs ~f:Lib_name.of_string |> Lib_name.Set.of_list
  in
  let other_formats =
    List.filter Output_format.all ~f:(fun f ->
      not (List.mem output_formats f ~equal:Poly.equal))
  in
  let needs_search_db =
    List.exists output_formats ~f:(fun f ->
      match (f : Output_format.t) with
      | Html | Json -> true
      | Markdown -> false)
  in
  let rules =
    Rules.collect_unit (fun () ->
      let* search_db =
        if needs_search_db
        then (
          let visible = List.filter all_artifacts ~f:(fun a -> not (Artifact.hidden a)) in
          let dir = Paths.output ctx Html (Pkg pkg) in
          let odocls = List.map visible ~f:(fun a -> Artifact.odocl_file ctx a) in
          let+ db = Sherlodoc.search_db sctx ~dir ~external_odocls:[] odocls in
          Some db)
        else Memo.return None
      in
      let* () =
        Memo.parallel_iter output_formats ~f:(fun output_format ->
          generate_html_for_package
            sctx
            ~ctx
            ~pkg
            ~search_db
            ~all_artifacts
            ~output_format
            ())
      in
      Memo.parallel_iter other_formats ~f:(fun other_format ->
        let other_alias = Output_format.alias other_format ~dir in
        Rules.Produce.Alias.add_deps other_alias (Action_builder.return ())
        >>> Memo.parallel_iter (Lib_name.Set.to_list all_lib_names) ~f:(fun lib_name ->
          let lib_dir = dir ++ Lib_name.to_string lib_name in
          let lib_other_alias = Output_format.alias other_format ~dir:lib_dir in
          Rules.Produce.Alias.add_deps lib_other_alias (Action_builder.return ()))))
  in
  let build_dir_only_sub_dirs =
    Build_config.Gen_rules.Build_only_sub_dirs.singleton
      ~dir
      (Subdir_set.of_list lib_subdirs)
  in
  Memo.return (Build_config.Gen_rules.make ~build_dir_only_sub_dirs rules)
;;

let setup_package_aliases_format sctx (pkg : Package.t) (output : Output_format.t) =
  let ctx = Super_context.context sctx in
  let name = Package.name pkg in
  let alias =
    let pkg_dir = Package.dir pkg in
    let dir = Path.Build.append_source (Context.build_dir ctx) pkg_dir in
    Output_format.alias output ~dir
  in
  let* libs = libs_of_pkg (Context.name ctx) ~pkg:name in
  let deps =
    let pkg_alias = Dep.format_alias output ctx (Target.Pkg name) in
    let lib_aliases =
      List.map libs ~f:(fun l -> Dep.format_alias output ctx (Target.Lib l))
    in
    pkg_alias :: lib_aliases
    |> Dune_engine.Dep.Set.of_list_map ~f:Dune_engine.Dep.alias
    |> Action_builder.deps
  in
  Rules.Produce.Alias.add_deps alias deps
;;

let setup_package_aliases sctx (pkg : Package.t) =
  Output_format.iter ~f:(setup_package_aliases_format sctx pkg)
;;

let gen_project_rules sctx project =
  Dune_project.packages project
  |> Dune_lang.Package_name.Map.to_seq
  |> Memo.parallel_iter_seq ~f:(fun (_, (pkg : Package.t)) ->
    (* setup @doc to build the correct html for the package *)
    setup_package_aliases sctx pkg)
;;

let setup_private_library_doc_alias sctx ~scope ~dir (l : Library.t) =
  match l.visibility with
  | Public _ -> Memo.return ()
  | Private _ ->
    let ctx = Super_context.context sctx in
    let* lib =
      let src_dir = Path.drop_optional_build_context_src_exn (Path.build dir) in
      Lib.DB.find_lib_id_even_when_hidden
        (Scope.libs scope)
        (Local (Library.to_lib_id ~src_dir l))
      >>| Option.value_exn
    in
    let lib = Target.Lib (Lib.Local.of_lib_exn lib) in
    Rules.Produce.Alias.add_deps
      (Alias.make ~dir Alias0.private_doc)
      (lib |> Dep.format_alias Html ctx |> Dune_engine.Dep.alias |> Action_builder.dep)
;;

let handle_mlds_dir sctx ~pkg_name =
  let ctx = Super_context.context sctx in
  let* _all_artifacts, _lib_subdirs, gen_index, _pkg =
    Odoc_discovery.discover_package_artifacts
      sctx
      ctx
      ~default_index
      ~pkg_or_lib_unique_name:pkg_name
  in
  match gen_index with
  | None -> Memo.return ()
  | Some (path, content) -> add_rule sctx (Action_builder.write_file path content)
;;

let handle_output_root sctx ~output_formats =
  let ctx = Super_context.context sctx in
  let directory_targets =
    if List.mem output_formats Output_format.Html ~equal:Poly.equal
    then Path.Build.Map.singleton (Paths.odoc_support ctx) Loc.none
    else Path.Build.Map.empty
  in
  let rules =
    Rules.collect_unit (fun () ->
      (if List.mem output_formats Output_format.Html ~equal:Poly.equal
       then
         Sherlodoc.sherlodoc_dot_js sctx ~dir:(Paths.output_root ctx Html)
         >>> setup_css_rule sctx
       else Memo.return ())
      >>> Memo.parallel_iter output_formats ~f:(fun output_format ->
        setup_toplevel_index_rule sctx output_format
        >>>
        let alias =
          Output_format.alias output_format ~dir:(Paths.output_root ctx output_format)
        in
        let toplevel_path = Output_format.toplevel_index_path output_format ctx in
        Dep.add_file_deps alias [ Path.build toplevel_path ]
        >>> setup_toplevel_index_deps sctx output_format))
  in
  Memo.return (Build_config.Gen_rules.make ~directory_targets rules)
;;

let gen_rules sctx ~dir rest =
  let ctx = Super_context.context sctx in
  let redirect () = Memo.return (Gen_rules.redirect_to_parent Gen_rules.Rules.empty) in
  let empty_rules () =
    Memo.return (Build_config.Gen_rules.make (Memo.return Rules.empty))
  in
  let output_artifacts output_formats pkg_or_lib_name =
    handle_output_artifacts sctx ~dir ~output_formats ~pkg_or_lib_name
  in
  let handle_mlds_pkg pkg_name =
    let pkg = Package.Name.of_string pkg_name in
    let* all_libs = libs_of_pkg (Context.name ctx) ~pkg in
    let lib_subdirs =
      List.map all_libs ~f:(fun lib ->
        Lib.name (Lib.Local.to_lib lib) |> Lib_name.to_string)
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
  (* HTML/JSON share [_html/]; Markdown lives in [_markdown/]. *)
  | [ "_html" ] -> handle_output_root sctx ~output_formats:[ Html; Json ]
  | [ "_html"; pkg_or_lib_name ] -> output_artifacts [ Html; Json ] pkg_or_lib_name
  | [ "_markdown" ] -> handle_output_root sctx ~output_formats:[ Markdown ]
  | [ "_markdown"; pkg_or_lib_name ] -> output_artifacts [ Markdown ] pkg_or_lib_name
  | ("_html" | "_markdown") :: _ :: _ :: _ -> redirect ()
  (* Compiled/linked odoc trees *)
  | [ "_odoc" ] | [ "_odoc"; "pkg" ] | [ "_odocls" ] | [ "_mlds" ] -> empty_rules ()
  | [ "_odoc"; "pkg"; pkg_name ] -> handle_odoc_pkg_pages sctx ~dir ~pkg_name
  | [ "_odocls"; pkg_or_lib_name ] -> handle_odocl_artifacts sctx ~pkg_or_lib_name
  | [ "_mlds"; pkg_name ] -> handle_mlds_pkg pkg_name
  | ("_odoc" | "_odocls" | "_mlds") :: _ :: _ :: _ -> redirect ()
  | _ -> empty_rules ()
;;
