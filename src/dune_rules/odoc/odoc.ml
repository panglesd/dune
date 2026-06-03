open Import
open Memo.O
module Gen_rules = Build_config.Gen_rules

let ( ++ ) = Path.Build.relative

type target = Odoc_target.t =
  | Lib of Lib.Local.t
  | Pkg of Package.Name.t

let add_rule sctx =
  let dir = Super_context.context sctx |> Context.build_dir in
  Super_context.add_rule sctx ~dir
;;

module Paths = Odoc_paths

module Output_format = struct
  type t = Odoc_paths.output_format =
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

  let alias t ~dir =
    match t with
    | Html -> Alias.make Alias0.doc ~dir
    | Json -> Alias.make Alias0.doc_json ~dir
    | Markdown -> Alias.make Alias0.doc_markdown ~dir
  ;;

  let toplevel_index_path format ctx =
    let base = Paths.toplevel_index ctx in
    match format with
    | Html -> base
    | Json -> Path.Build.extend_basename base ~suffix:Filename.json
    | Markdown -> Paths.markdown_index ctx
  ;;
end

let output_dir_for_format ctx format target =
  match (format : Output_format.t) with
  | Html | Json -> Paths.html ctx target
  | Markdown -> Paths.markdown ctx target
;;

module Artifact = Odoc_artifact

module Dep : sig
  (** [format_alias output ctx target] returns the alias that depends on all
      targets produced by odoc for [target] in output format [output]. *)
  val format_alias : Output_format.t -> Context.t -> target -> Alias.t

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
  val setup_deps : Context.t -> target -> Path.Set.t -> unit Memo.t
end = struct
  let format_alias f ctx m = Output_format.alias f ~dir:(output_dir_for_format ctx f m)
  let alias = Alias.make (Alias.Name.of_string ".odoc-all")

  let deps ctx pkg requires =
    let open Action_builder.O in
    let* libs = Resolve.read requires in
    Action_builder.deps
      (let init =
         match pkg with
         | Some p -> Dep.Set.singleton (Dep.alias (alias ~dir:(Paths.odocs ctx (Pkg p))))
         | None -> Dep.Set.empty
       in
       List.fold_left libs ~init ~f:(fun acc (lib : Lib.t) ->
         match Lib.Local.of_lib lib with
         | None -> acc
         | Some lib ->
           let dir = Paths.odocs ctx (Lib lib) in
           let alias = alias ~dir in
           Dep.Set.add acc (Dep.alias alias)))
  ;;

  let alias ctx m = alias ~dir:(Paths.odocs ctx m)

  let setup_deps ctx m files =
    Rules.Produce.Alias.add_deps (alias ctx m) (Action_builder.path_set files)
  ;;
end

module Flags = struct
  type warnings = Dune_env.Odoc.warnings =
    | Fatal
    | Nonfatal

  type t = { warnings : warnings }

  let default = { warnings = Nonfatal }

  let get ~dir =
    Env_stanza_db.value ~default ~dir ~f:(fun config ->
      match config.odoc.warnings with
      | None -> Memo.return None
      | Some warnings -> Memo.return (Some { warnings }))
    |> Action_builder.of_memo
  ;;
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
  let dir = Option.value dir ~default:(Path.build (Paths.root ctx)) in
  let base_flags =
    let open Action_builder.O in
    let* () = Action_builder.return () in
    match flags_for with
    | None -> Action_builder.return Command.Args.empty
    | Some path -> odoc_base_flags quiet path
  in
  let deps = Action_builder.env_var "ODOC_SYNTAX" in
  let open Action_builder.With_targets.O in
  Action_builder.with_no_targets deps
  >>> Command.run_dyn_prog ~dir program [ A command; Dyn base_flags; S args ]
;;

let module_deps (m : Module.t) ~sctx ~ctx ~lib ~obj_dir ~modules ~for_ =
  let sandbox = Compilation_mode.default_sandbox for_ in
  let ml_kind =
    (* When a module has no .mli, use the dependencies for the .ml *)
    if Module.has m ~ml_kind:Intf then Ml_kind.Intf else Ml_kind.Impl
  in
  Action_builder.dyn_paths_unit
    (let open Action_builder.O in
     let+ deps =
       Dep_rules.read_immediate_deps_of ~sandbox ~sctx ~obj_dir ~modules ~ml_kind m
     in
     List.map deps ~f:(fun m -> Path.build (Paths.lib_module_odoc ctx lib m)))
;;

let compile_module
      sctx
      ~lib
      ~obj_dir
      ~modules
      ~for_
      (m : Module.t)
      ~includes:(file_deps, iflags)
      ~pkg_or_lnu
  =
  let ctx = Super_context.context sctx in
  let odoc_file = Paths.lib_module_odoc ctx lib m in
  let cmti_file =
    Obj_dir.Module.cmti_file
      ~cm_kind:
        (match for_ with
         | Compilation_mode.Ocaml -> Ocaml Cmi
         | Melange -> Melange Cmi)
      obj_dir
      m
  in
  let+ () =
    let action_with_targets =
      let doc_dir = Path.build (Paths.odocs ctx (Lib lib)) in
      let run_odoc =
        run_odoc
          sctx
          ~dir:doc_dir
          "compile"
          ~quiet:false
            (* Warning configuration follows the library's environment, which
               lives at the source/obj dir of the [.cmti], not the relocated
               odoc output directory. *)
          ~flags_for:(Some cmti_file)
          [ A "-I"
          ; Path doc_dir
          ; iflags
          ; As [ "--pkg"; pkg_or_lnu ]
          ; A "--enable-missing-root-warning"
          ; A "-o"
          ; Target odoc_file
          ; Dep (Path.build cmti_file)
          ]
      in
      let open Action_builder.With_targets.O in
      Action_builder.with_no_targets file_deps
      >>> Action_builder.with_no_targets
            (module_deps m ~sctx ~ctx ~lib ~obj_dir ~modules ~for_)
      >>> run_odoc
    in
    add_rule sctx action_with_targets
  in
  m, odoc_file
;;

let compile_mld sctx (m : Odoc_discovery.Mld.t) ~includes ~doc_dir ~pkg =
  let odoc_file = Odoc_discovery.Mld.odoc_file m ~doc_dir in
  let odoc_input = Odoc_discovery.Mld.odoc_input m in
  let run_odoc =
    run_odoc
      sctx
      ~dir:(Path.build doc_dir)
      "compile"
      ~quiet:false
      ~flags_for:(Some odoc_input)
      [ Command.Args.dyn includes
      ; As [ "--pkg"; Package.Name.to_string pkg ]
      ; A "-o"
      ; Target odoc_file
      ; Dep (Path.build odoc_input)
      ]
  in
  let+ () = add_rule sctx run_odoc in
  odoc_file
;;

let odoc_include_flags ctx pkg requires =
  Resolve.args
    (let open Resolve.O in
     let+ libs = requires in
     let paths =
       List.fold_left libs ~init:Path.Set.empty ~f:(fun paths lib ->
         match Lib.Local.of_lib lib with
         | None -> paths
         | Some lib -> Path.Set.add paths (Path.build (Paths.odocs ctx (Lib lib))))
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

let link_odoc_rules sctx (odoc_file : Artifact.t) ~pkg ~requires =
  let ctx = Super_context.context sctx in
  let deps = Dep.deps ctx pkg requires in
  let dir = Path.build (Path.Build.parent_exn (Artifact.odocl_file ctx odoc_file)) in
  let run_odoc =
    run_odoc
      sctx
      ~dir
      "link"
      ~quiet:false
      ~flags_for:(Some (Artifact.odoc_file odoc_file))
      [ odoc_include_flags ctx pkg requires
      ; A "--enable-missing-root-warning"
      ; A "-o"
      ; Target (Artifact.odocl_file ctx odoc_file)
      ; Dep (Path.build (Artifact.odoc_file odoc_file))
      ]
  in
  add_rule
    sctx
    (let open Action_builder.With_targets.O in
     Action_builder.with_no_targets deps >>> run_odoc)
;;

let setup_library_odoc_rules sctx (local_lib : Lib.Local.t) =
  (* Using the proper package name doesn't actually work since odoc assumes that
     a package contains only 1 library *)
  let pkg_or_lnu = Odoc_scope.pkg_or_lnu (Lib.Local.to_lib local_lib) in
  let ctx = Super_context.context sctx in
  let info = Lib.Local.info local_lib in
  let obj_dir = Lib_info.obj_dir info in
  let for_ = (Compilation_mode.of_mode_set (Lib_info.modes info)).for_merlin in
  let* modules = Dir_contents.modules_of_local_lib sctx local_lib ~for_ in
  let* includes =
    let+ requires = Lib.requires (Lib.Local.to_lib local_lib) ~for_ in
    let package = Lib_info.package info in
    let odoc_include_flags =
      Command.Args.memo (odoc_include_flags ctx package requires)
    in
    Dep.deps ctx package requires, odoc_include_flags
  in
  let with_vlib_modules = Modules.With_vlib.modules modules in
  modules
  |> Modules.fold ~init:[] ~f:(fun m acc ->
    let compiled =
      compile_module
        sctx
        ~lib:local_lib
        ~obj_dir
        ~modules:with_vlib_modules
        ~for_
        ~includes
        ~pkg_or_lnu
        m
    in
    compiled :: acc)
  |> Memo.all_concurrently
  >>| Path.Set.of_list_map ~f:(fun (_, p) -> Path.build p)
  >>= Dep.setup_deps ctx (Lib local_lib)
;;

let setup_generate sctx ~search_db odoc_file out =
  let ctx = Super_context.context sctx in
  let odoc_support_path = Paths.odoc_support ctx in
  let command, output_dir, args =
    match out with
    | Output_format.Markdown ->
      ( "markdown-generate"
      , Paths.markdown_root ctx
      , [ Command.Args.A "-o"
        ; Command.Args.Path (Path.build (Paths.markdown_root ctx))
        ; Command.Args.Dep (Path.build (Artifact.odocl_file ctx odoc_file))
        ; Command.Args.Hidden_targets [ Artifact.output_file ctx out odoc_file ]
        ] )
    | Html | Json ->
      let search_args =
        match search_db with
        | None -> Command.Args.empty
        | Some search_db ->
          Sherlodoc.odoc_args sctx ~search_db ~dir_sherlodoc_dot_js:(Paths.html_root ctx)
      in
      ( "html-generate"
      , Paths.html_root ctx
      , [ search_args
        ; Command.Args.A "-o"
        ; Command.Args.Path (Path.build (Paths.html_root ctx))
        ; Command.Args.A "--support-uri"
        ; Command.Args.Path (Path.build odoc_support_path)
        ; Command.Args.A "--theme-uri"
        ; Command.Args.Path (Path.build odoc_support_path)
        ; Command.Args.Dep (Path.build (Artifact.odocl_file ctx odoc_file))
        ; Output_format.args out
        ; Command.Args.Hidden_targets [ Artifact.output_file ctx out odoc_file ]
        ] )
  in
  let run_odoc =
    run_odoc sctx ~dir:(Path.build output_dir) command ~quiet:false ~flags_for:None args
  in
  add_rule sctx run_odoc
;;

let setup_generate_html_and_json sctx ~search_db odoc_file =
  let* () = setup_generate sctx ~search_db:(Some search_db) odoc_file Html in
  setup_generate sctx ~search_db:(Some search_db) odoc_file Json
;;

let setup_generate_markdown sctx odoc_file =
  setup_generate sctx ~search_db:None odoc_file Markdown
;;

let setup_support_files_rule sctx ~dir =
  let ctx = Super_context.context sctx in
  let run_odoc =
    let cmd =
      run_odoc
        sctx
        ~dir:(Path.build (Context.build_dir ctx))
        "support-files"
        ~quiet:false
        ~flags_for:None
        [ A "-o"; Path (Path.build dir) ]
    in
    Action_builder.With_targets.add_directories ~directory_targets:[ dir ] cmd
  in
  add_rule sctx run_odoc
;;

let setup_css_rule sctx =
  setup_support_files_rule sctx ~dir:(Paths.odoc_support (Super_context.context sctx))
;;

let setup_toplevel_index_rule sctx output =
  let* packages = Dune_load.packages () in
  let index = Odoc_discovery.Toplevel_index.of_packages packages output in
  let content = Odoc_discovery.Toplevel_index.content output index in
  let ctx = Super_context.context sctx in
  let path = Output_format.toplevel_index_path output ctx in
  add_rule sctx (Action_builder.write_file path content)
;;

let setup_lib_odocl_rules_def =
  let module Input = struct
    module Super_context = Super_context.As_memo_key

    type t = Super_context.t * Lib.Local.t * Lib.t list Resolve.t

    let equal (sc1, l1, r1) (sc2, l2, r2) =
      Super_context.equal sc1 sc2
      && Lib.Local.equal l1 l2
      && Resolve.equal (List.equal Lib.equal) r1 r2
    ;;

    let hash (sc, l, r) =
      Poly.hash
        (Super_context.hash sc, Lib.Local.hash l, Resolve.hash (List.hash Lib.hash) r)
    ;;

    let to_dyn _ = Dyn.Opaque
  end
  in
  let f (sctx, lib, requires) =
    let* odocs = Odoc_discovery.odoc_artefacts sctx (Lib lib) in
    let pkg = Lib_info.package (Lib.Local.info lib) in
    Memo.parallel_iter odocs ~f:(fun odoc -> link_odoc_rules sctx ~pkg ~requires odoc)
  in
  Memo.With_implicit_output.create
    "setup_library_odocls_rules"
    ~implicit_output:Rules.implicit_output
    ~input:(module Input)
    f
;;

let setup_lib_odocl_rules sctx lib ~requires =
  Memo.With_implicit_output.exec setup_lib_odocl_rules_def (sctx, lib, requires)
;;

let setup_pkg_rules_def memo_name f =
  let module Input = struct
    module Super_context = Super_context.As_memo_key

    type t = Super_context.t * Package.Name.t * Compilation_mode.t

    let equal (s1, p1, c1) (s2, p2, c2) =
      Package.Name.equal p1 p2
      && Super_context.equal s1 s2
      && Compilation_mode.equal c1 c2
    ;;

    let hash = Tuple.T3.hash Super_context.hash Package.Name.hash Poly.hash
    let to_dyn (_, package, _) = Package.Name.to_dyn package
  end
  in
  Memo.With_implicit_output.create
    memo_name
    ~input:(module Input)
    ~implicit_output:Rules.implicit_output
    f
;;

let setup_pkg_odocl_rules_def =
  let f (sctx, pkg, for_) =
    let* libs =
      Super_context.context sctx |> Context.name |> Odoc_discovery.libs_of_pkg ~pkg
    in
    let* requires =
      let libs = (libs :> Lib.t list) in
      Lib.closure libs ~linking:false ~for_
    in
    let* () = Memo.parallel_iter libs ~f:(setup_lib_odocl_rules sctx ~requires)
    and* _ =
      let* pkg_odocs = Odoc_discovery.odoc_artefacts sctx (Pkg pkg) in
      let pkg = Some pkg in
      let+ () =
        Memo.parallel_iter pkg_odocs ~f:(fun odoc ->
          link_odoc_rules sctx ~pkg ~requires odoc)
      in
      pkg_odocs
    and* _ =
      Memo.parallel_map libs ~f:(fun lib -> Odoc_discovery.odoc_artefacts sctx (Lib lib))
    in
    Memo.return ()
  in
  setup_pkg_rules_def "setup-package-odocls-rules" f
;;

let setup_pkg_odocl_rules sctx ~pkg ~for_ : unit Memo.t =
  Memo.With_implicit_output.exec setup_pkg_odocl_rules_def (sctx, pkg, for_)
;;

let out_file ctx (output : Output_format.t) odoc = Artifact.output_file ctx output odoc

let out_files ctx (output : Output_format.t) odocs =
  let extra_files =
    match output with
    | Html -> [ Path.build (Paths.odoc_support ctx) ]
    | Json -> []
    | Markdown -> []
  in
  Path.build (Output_format.toplevel_index_path output ctx)
  :: List.rev_append
       extra_files
       (List.map odocs ~f:(fun odoc -> Path.build (out_file ctx output odoc)))
;;

let add_format_alias_deps ctx format target odocs =
  match (format : Output_format.t) with
  | Markdown ->
    (* skip alias deps for markdown since package directories are directory targets *)
    Memo.return ()
  | Html | Json ->
    let paths = out_files ctx format odocs in
    Rules.Produce.Alias.add_deps
      (Dep.format_alias format ctx target)
      (Action_builder.paths paths)
;;

let setup_lib_html_rules_def =
  let module Input = struct
    module Super_context = Super_context.As_memo_key

    type t = Super_context.t * Lib.Local.t

    let equal (sc1, l1) (sc2, l2) = Super_context.equal sc1 sc2 && Lib.Local.equal l1 l2
    let hash = Tuple.T2.hash Super_context.hash Lib.Local.hash
    let to_dyn _ = Dyn.Opaque
  end
  in
  let f (sctx, lib) =
    let ctx = Super_context.context sctx in
    let target = Lib lib in
    let* odocs = Odoc_discovery.odoc_artefacts sctx target in
    let* () = add_format_alias_deps ctx Html target odocs in
    add_format_alias_deps ctx Json target odocs
  in
  Memo.With_implicit_output.create
    "setup-library-html-rules"
    ~implicit_output:Rules.implicit_output
    ~input:(module Input)
    f
;;

let search_db_for_lib sctx lib =
  let target = Lib lib in
  let ctx = Super_context.context sctx in
  let dir = Paths.html ctx target in
  let* odocs = Odoc_discovery.odoc_artefacts sctx target in
  let odocls = List.map odocs ~f:(Artifact.odocl_file ctx) in
  Sherlodoc.search_db sctx ~dir ~external_odocls:[] odocls
;;

let setup_lib_html_rules sctx ~search_db lib =
  let target = Lib lib in
  let* odocs = Odoc_discovery.odoc_artefacts sctx target in
  let* () =
    Memo.parallel_iter odocs ~f:(fun odoc ->
      setup_generate_html_and_json sctx ~search_db odoc)
  in
  Memo.With_implicit_output.exec setup_lib_html_rules_def (sctx, lib)
;;

let setup_pkg_html_rules_def =
  let f (sctx, pkg, _for_) =
    let ctx = Super_context.context sctx in
    let* libs = Context.name ctx |> Odoc_discovery.libs_of_pkg ~pkg in
    let dir = Paths.html ctx (Pkg pkg) in
    let* pkg_odocs = Odoc_discovery.odoc_artefacts sctx (Pkg pkg) in
    let* lib_odocs =
      Memo.List.concat_map libs ~f:(fun lib ->
        Odoc_discovery.odoc_artefacts sctx (Lib lib))
    in
    let all_odocs = pkg_odocs @ lib_odocs in
    let* search_db =
      let odocls = List.map all_odocs ~f:(Artifact.odocl_file ctx) in
      Sherlodoc.search_db sctx ~dir ~external_odocls:[] odocls
    in
    let* () = Memo.parallel_iter libs ~f:(setup_lib_html_rules sctx ~search_db) in
    let* () =
      Memo.parallel_iter pkg_odocs ~f:(setup_generate_html_and_json ~search_db sctx)
    in
    let* () = add_format_alias_deps ctx Html (Pkg pkg) all_odocs in
    add_format_alias_deps ctx Json (Pkg pkg) all_odocs
  in
  setup_pkg_rules_def "setup-package-html-rules" f
;;

let setup_pkg_html_rules sctx ~pkg ~for_ : unit Memo.t =
  Memo.With_implicit_output.exec setup_pkg_html_rules_def (sctx, pkg, for_)
;;

let setup_lib_markdown_rules sctx lib =
  let target = Lib lib in
  let* () =
    match Lib_info.package (Lib.Local.info lib) with
    | Some _ -> Memo.return ()
    | None ->
      Odoc_discovery.odoc_artefacts sctx target
      >>= Memo.parallel_iter ~f:(fun odoc -> setup_generate_markdown sctx odoc)
  in
  let ctx = Super_context.context sctx in
  Odoc_discovery.odoc_artefacts sctx (Lib lib)
  >>= add_format_alias_deps ctx Markdown target
;;

let setup_pkg_markdown_rules sctx ~pkg =
  let ctx = Super_context.context sctx in
  let* libs = Context.name ctx |> Odoc_discovery.libs_of_pkg ~pkg in
  let* all_odocs =
    let* pkg_odocs = Odoc_discovery.odoc_artefacts sctx (Pkg pkg) in
    let+ lib_odocs =
      Memo.List.concat_map libs ~f:(fun lib ->
        Odoc_discovery.odoc_artefacts sctx (Lib lib))
    in
    pkg_odocs @ lib_odocs
  in
  let* () =
    if List.is_empty all_odocs
    then Memo.return ()
    else (
      let pkg_markdown_dir = Paths.markdown ctx (Pkg pkg) in
      let markdown_root = Paths.markdown_root ctx in
      let actions =
        List.map all_odocs ~f:(fun odoc ->
          run_odoc
            sctx
            ~dir:(Path.build markdown_root)
            "markdown-generate"
            ~quiet:false
            ~flags_for:None
            [ Command.Args.A "-o"
            ; Command.Args.Path (Path.build markdown_root)
            ; Command.Args.Dep (Path.build (Artifact.odocl_file ctx odoc))
            ])
      in
      let rule =
        Action_builder.progn actions
        |> Action_builder.With_targets.add_directories
             ~directory_targets:[ pkg_markdown_dir ]
      in
      add_rule sctx rule)
  in
  let* () = Memo.parallel_iter libs ~f:(setup_lib_markdown_rules sctx) in
  add_format_alias_deps ctx Markdown (Pkg pkg) all_odocs
;;

let setup_package_aliases_format sctx (pkg : Package.t) (output : Output_format.t) =
  let ctx = Super_context.context sctx in
  let name = Package.name pkg in
  let alias =
    let pkg_dir = Package.dir pkg in
    let dir = Path.Build.append_source (Context.build_dir ctx) pkg_dir in
    Output_format.alias output ~dir
  in
  match (output : Output_format.t) with
  | Markdown ->
    let directory_target = Paths.markdown ctx (Pkg name) in
    let toplevel_index = Paths.markdown_index ctx in
    let deps =
      let open Action_builder.O in
      let+ () = Action_builder.path (Path.build directory_target)
      and+ () = Action_builder.path (Path.build toplevel_index) in
      ()
    in
    Rules.Produce.Alias.add_deps alias deps
  | Html | Json ->
    let* libs =
      Context.name ctx
      |> Odoc_discovery.libs_of_pkg ~pkg:name
      >>| List.map ~f:(fun lib -> Lib lib)
    in
    let deps =
      Pkg name :: libs
      |> List.map ~f:(Dep.format_alias output ctx)
      |> Dune_engine.Dep.Set.of_list_map ~f:(fun f -> Dune_engine.Dep.alias f)
      |> Action_builder.deps
    in
    Rules.Produce.Alias.add_deps alias deps
;;

let setup_package_aliases sctx (pkg : Package.t) =
  Output_format.iter ~f:(setup_package_aliases_format sctx pkg)
;;

let package_mlds =
  let memo =
    Memo.create
      "package-mlds"
      ~input:(module Super_context.As_memo_key.And_package_name)
      (fun (sctx, pkg) ->
         Rules.collect (fun () ->
           let* mlds, warnings = Odoc_discovery.mlds sctx pkg in
           Odoc_discovery.report_warnings warnings;
           let mlds = Odoc_discovery.check_mlds_no_dupes ~pkg ~mlds in
           let ctx = Super_context.context sctx in
           if String.Map.mem mlds "index"
           then Memo.return mlds
           else (
             let gen_mld = Paths.gen_mld_dir ctx pkg ++ "index.mld" in
             let* entry_modules = Odoc_discovery.entry_modules sctx ~pkg in
             let+ () =
               add_rule
                 sctx
                 (Action_builder.write_file
                    gen_mld
                    (Odoc_discovery.default_index ~pkg entry_modules))
             in
             String.Map.set mlds "index" (gen_mld, "index"))))
  in
  fun sctx ~pkg -> Memo.exec memo (sctx, pkg)
;;

let setup_package_odoc_rules sctx ~pkg =
  let* mlds = package_mlds sctx ~pkg >>| fst in
  let ctx = Super_context.context sctx in
  (* CR-someday jeremiedimino: it is weird that we drop the [Package.t] and go
     back to a package name here. Need to try and change that one day. *)
  let* odocs =
    String.Map.values mlds
    |> Memo.parallel_map ~f:(fun (path, name) ->
      compile_mld
        sctx
        (Odoc_discovery.Mld.create ~path ~name)
        ~pkg
        ~doc_dir:(Paths.odocs ctx (Pkg pkg))
        ~includes:(Action_builder.return []))
  in
  Path.Set.of_list_map ~f:Path.build odocs |> Dep.setup_deps ctx (Pkg pkg)
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
    let lib = Lib (Lib.Local.of_lib_exn lib) in
    Rules.Produce.Alias.add_deps
      (Alias.make ~dir Alias0.private_doc)
      (lib |> Dep.format_alias Html ctx |> Dune_engine.Dep.alias |> Action_builder.dep)
;;

let has_rules ?(directory_targets = Path.Build.Map.empty) m =
  let rules = Rules.collect_unit (fun () -> m) in
  Memo.return (Gen_rules.make ~directory_targets rules)
;;

let with_package pkg ~f =
  let pkg = Package.Name.of_string pkg in
  let* packages = Dune_load.packages () in
  match Package.Name.Map.find packages pkg with
  | Some pkg -> has_rules (f pkg)
  | None -> Memo.return Gen_rules.no_rules
;;

let gen_rules sctx ~dir rest =
  match rest with
  | [] ->
    Memo.return
      (Build_config.Gen_rules.make
         ~build_dir_only_sub_dirs:
           (Build_config.Gen_rules.Build_only_sub_dirs.singleton ~dir Subdir_set.all)
         (Memo.return Rules.empty))
  | [ "_html" ] ->
    let ctx = Super_context.context sctx in
    let directory_targets = Path.Build.Map.singleton (Paths.odoc_support ctx) Loc.none in
    has_rules
      ~directory_targets
      (Sherlodoc.sherlodoc_dot_js sctx ~dir:(Paths.html_root ctx)
       >>> setup_css_rule sctx
       >>> setup_toplevel_index_rule sctx Html
       >>> setup_toplevel_index_rule sctx Json)
  | [ "_markdown" ] ->
    let* packages = Dune_load.packages () in
    let ctx = Super_context.context sctx in
    let all_package_dirs =
      Package.Name.Map.to_list packages
      |> List.map ~f:(fun (_, (pkg : Package.t)) ->
        let pkg_name = Package.name pkg in
        Paths.markdown ctx (Pkg pkg_name))
    in
    let directory_targets =
      List.fold_left all_package_dirs ~init:Path.Build.Map.empty ~f:(fun acc dir ->
        Path.Build.Map.set acc dir Loc.none)
    in
    has_rules
      ~directory_targets
      (let* () = setup_toplevel_index_rule sctx Markdown in
       Package.Name.Map.to_seq packages
       |> Memo.parallel_iter_seq ~f:(fun (_, (pkg : Package.t)) ->
         let pkg_name = Package.name pkg in
         setup_pkg_markdown_rules sctx ~pkg:pkg_name))
  | [ "_markdown"; _lib_unique_name_or_pkg ] ->
    (* package directories are directory targets *)
    Memo.return Gen_rules.no_rules
  | [ "_mlds"; pkg ] ->
    with_package pkg ~f:(fun pkg ->
      let pkg = Package.name pkg in
      let* _mlds, rules = package_mlds sctx ~pkg in
      Rules.produce rules)
  | [ "_odoc"; "pkg"; pkg ] ->
    with_package pkg ~f:(fun pkg ->
      let pkg = Package.name pkg in
      setup_package_odoc_rules sctx ~pkg)
  | [ "_odoc"; "pkg" ] -> Memo.return (Gen_rules.redirect_to_parent Gen_rules.Rules.empty)
  | [ "_odoc"; lib_unique_name ] ->
    has_rules
      ((* Each library's modules are compiled into its own
          [_doc/_odoc/<lib-unique-name>] directory, so the directory name
          resolves to a single library. *)
       let ctx = Super_context.context sctx in
       let* lib, lib_db =
         Odoc_scope.Scope_key.of_string (Context.name ctx) lib_unique_name
       in
       let* lib =
         let+ lib = Lib.DB.find lib_db lib in
         Option.bind ~f:Lib.Local.of_lib lib
       in
       match lib with
       | None -> Memo.return ()
       | Some lib -> setup_library_odoc_rules sctx lib)
  | [ "_odocls"; lib_unique_name_or_pkg ] ->
    has_rules
      ((* TODO we can be a better with the error handling in the case where
          lib_unique_name_or_pkg is neither a valid pkg or lnu *)
       let ctx = Super_context.context sctx in
       let* lib, lib_db =
         Odoc_scope.Scope_key.of_string (Context.name ctx) lib_unique_name_or_pkg
       in
       (* jeremiedimino: why isn't [None] some kind of error here? *)
       let* lib =
         let+ lib = Lib.DB.find lib_db lib in
         Option.bind ~f:Lib.Local.of_lib lib
       in
       let for_ =
         match lib with
         | Some lib ->
           let modes =
             Lib_info.modes (Lib.Local.info lib) |> Compilation_mode.of_mode_set
           in
           modes.for_merlin
         | None -> Ocaml
       in
       let+ () =
         match lib with
         | None -> Memo.return ()
         | Some lib ->
           (match Lib_info.package (Lib.Local.info lib) with
            | None ->
              let* requires = Lib.closure [ Lib.Local.to_lib lib ] ~linking:false ~for_ in
              setup_lib_odocl_rules sctx lib ~requires
            | Some pkg -> setup_pkg_odocl_rules sctx ~pkg ~for_)
       and+ () =
         let* packages = Dune_load.packages () in
         match
           Package.Name.Map.find packages (Package.Name.of_string lib_unique_name_or_pkg)
         with
         | None -> Memo.return ()
         | Some pkg ->
           let name = Package.name pkg in
           setup_pkg_odocl_rules sctx ~pkg:name ~for_
       in
       ())
  | [ "_html"; lib_unique_name_or_pkg ] ->
    has_rules
      ((* TODO we can be a better with the error handling in the case where
          lib_unique_name_or_pkg is neither a valid pkg or lnu *)
       let ctx = Super_context.context sctx in
       let* lib, lib_db =
         Odoc_scope.Scope_key.of_string (Context.name ctx) lib_unique_name_or_pkg
       in
       (* jeremiedimino: why isn't [None] some kind of error here? *)
       let* lib =
         let+ lib = Lib.DB.find lib_db lib in
         Option.bind ~f:Lib.Local.of_lib lib
       in
       let for_ =
         match lib with
         | Some lib ->
           let modes =
             Lib_info.modes (Lib.Local.info lib) |> Compilation_mode.of_mode_set
           in
           modes.for_merlin
         | None -> Ocaml
       in
       let+ () =
         match lib with
         | None -> Memo.return ()
         | Some lib ->
           (match Lib_info.package (Lib.Local.info lib) with
            | None ->
              (* lib with no package above it *)
              let* search_db = search_db_for_lib sctx lib in
              setup_lib_html_rules sctx ~search_db lib
            | Some pkg -> setup_pkg_html_rules sctx ~pkg ~for_)
       and+ () =
         let* packages = Dune_load.packages () in
         match
           Package.Name.Map.find packages (Package.Name.of_string lib_unique_name_or_pkg)
         with
         | None -> Memo.return ()
         | Some pkg ->
           let name = Package.name pkg in
           setup_pkg_html_rules sctx ~pkg:name ~for_
       in
       ())
  | _ -> Memo.return (Gen_rules.redirect_to_parent Gen_rules.Rules.empty)
;;
