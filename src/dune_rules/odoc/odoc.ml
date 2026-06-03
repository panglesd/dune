open Import
open Memo.O
module Gen_rules = Build_config.Gen_rules

let ( ++ ) = Path.Build.relative

type target = Odoc_target.t =
  | Lib of Lib.Local.t
  | Ext_lib of Lib.t
  | Pkg of Package.Name.t
  | Ext_pkg of Package.Name.t

let add_rule sctx =
  let dir = Super_context.context sctx |> Context.build_dir in
  Super_context.add_rule sctx ~dir
;;

module Paths = Odoc_paths
module Doc_mode = Odoc_mode

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

  let alias_name t (mode : Doc_mode.t) =
    match t, mode with
    | Html, Local_only -> Alias0.doc
    | Html, Full -> Alias0.doc_full
    | Json, Local_only -> Alias0.doc_json
    | Json, Full -> Alias0.doc_json_full
    | Markdown, Local_only -> Alias0.doc_markdown
    | Markdown, Full -> Alias0.doc_markdown_full
  ;;

  let alias t ~mode ~dir = Alias.make (alias_name t mode) ~dir

  let toplevel_index_path ~mode format ctx =
    match format with
    | Html -> Paths.toplevel_index ctx ~mode
    | Json -> Paths.json_index ctx ~mode
    | Markdown -> Paths.markdown_index ctx
  ;;
end

let output_dir_for_format ctx ~mode format target =
  match (format : Output_format.t) with
  | Html -> Paths.html ctx ~mode target
  | Json -> Paths.json ctx ~mode target
  | Markdown -> Paths.markdown ctx target
;;

(* The [@doc] (local-only) toplevel html index, for the CLI to report. *)
let toplevel_index ctx = Paths.toplevel_index ctx ~mode:Local_only

module Artifact = Odoc_artifact

module Dep : sig
  (** [format_alias output ctx target] returns the alias that depends on all
      targets produced by odoc for [target] in output format [output]. *)
  val format_alias : mode:Doc_mode.t -> Output_format.t -> Context.t -> target -> Alias.t

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

  (** The [.odoc-all] alias gathering every [.odoc] of [target]. *)
  val all_alias : Context.t -> target -> Alias.t
end = struct
  let format_alias ~mode f ctx m =
    Output_format.alias f ~mode ~dir:(output_dir_for_format ctx ~mode f m)
  ;;

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
  let all_alias = alias

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
  =
  let ctx = Super_context.context sctx in
  let odoc_file = Paths.lib_module_odoc ctx lib m in
  let parent_id = Paths.lib_parent_id lib in
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
          ; A "--enable-missing-root-warning"
          ; A "--output-dir"
          ; Path (Path.build (Paths.odoc_root ctx))
          ; As [ "--parent-id"; parent_id ]
          ; Hidden_targets [ odoc_file ]
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
  let ctx = Super_context.context sctx in
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
      ; A "--output-dir"
      ; Path (Path.build (Paths.odoc_root ctx))
      ; As [ "--parent-id"; Package.Name.to_string pkg ]
      ; Hidden_targets [ odoc_file ]
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
  let ctx = Super_context.context sctx in
  let info = Lib.Local.info local_lib in
  let obj_dir = Lib_info.obj_dir info in
  let for_ = (Compilation_mode.of_mode_set (Lib_info.modes info)).for_merlin in
  let* modules = Dir_contents.modules_of_local_lib sctx local_lib ~for_ in
  let* includes =
    let+ requires = Lib.requires (Lib.Local.to_lib local_lib) ~for_ in
    let odoc_include_flags = Command.Args.memo (odoc_include_flags ctx None requires) in
    (* Compiling a module does not involve the package itself: its mld pages
       reference modules (not the other way around), and the main library shares
       its [_odoc/<pkg>] directory with the package's [.odoc-all] alias, so
       depending on it would create a cycle. Inter-library dependencies are
       carried by [requires]. *)
    Dep.deps ctx None requires, odoc_include_flags
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
        m
    in
    compiled :: acc)
  |> Memo.all_concurrently
  >>| Path.Set.of_list_map ~f:(fun (_, p) -> Path.build p)
  >>= Dep.setup_deps ctx (Lib local_lib)
;;

(* Intra-library module dependencies of an external module. External libraries
   have no [.d] files, so we ask odoc directly via [compile-deps] and keep only
   the dependencies that are themselves modules of [lib]. *)
let external_module_deps sctx ~ctx ~lib ~odoc_of_module (m : Odoc_discovery.ext_module) =
  let doc_dir = Paths.odocs ctx (Ext_lib lib) in
  let deps_file = doc_dir ++ (Module_name.to_string m.name ^ ".deps") in
  let program = odoc_program sctx (Context.build_dir ctx) in
  let+ () =
    add_rule
      sctx
      (Command.run_dyn_prog
         program
         ~dir:(Path.build (Context.build_dir ctx))
         ~stdout_to:deps_file
         [ A "compile-deps"; Dep m.cmti ])
  in
  Action_builder.dyn_paths_unit
    (let open Action_builder.O in
     let+ lines = Action_builder.lines_of (Path.build deps_file) in
     List.filter_map lines ~f:(fun line ->
       match String.split ~on:' ' line with
       | [ name; _hash ] ->
         let dep = Module_name.of_checked_string name in
         if Module_name.equal dep m.name
         then None
         else Module_name.Map.find odoc_of_module dep |> Option.map ~f:Path.build
       | _ -> None))
;;

let compile_external_module sctx ~lib ~odoc_of_module (m : Odoc_discovery.ext_module) =
  let ctx = Super_context.context sctx in
  let parent_id = Paths.ext_lib_parent_id lib in
  let doc_dir = Path.build (Paths.odocs ctx (Ext_lib lib)) in
  let* module_deps = external_module_deps sctx ~ctx ~lib ~odoc_of_module m in
  let run_odoc =
    run_odoc
      sctx
      ~dir:doc_dir
      "compile"
      ~quiet:true
      ~flags_for:None
      [ A "-I"
      ; Path doc_dir
      ; A "--enable-missing-root-warning"
      ; A "--output-dir"
      ; Path (Path.build (Paths.odoc_root ctx))
      ; As [ "--parent-id"; parent_id ]
      ; Hidden_targets [ m.odoc_file ]
      ; Dep m.cmti
      ]
  in
  let+ () =
    add_rule
      sctx
      (let open Action_builder.With_targets.O in
       Action_builder.with_no_targets module_deps >>> run_odoc)
  in
  m.odoc_file
;;

(* Compile the [.odoc] files of an external (installed) library. Compilation is
   quiet (no warn-error on artifacts we do not own). *)
let setup_external_lib_odoc_rules sctx (lib : Lib.t) =
  let ctx = Super_context.context sctx in
  let* modules = Odoc_discovery.external_lib_modules sctx lib in
  let odoc_of_module =
    Module_name.Map.of_list_map_exn modules ~f:(fun m ->
      m.Odoc_discovery.name, m.odoc_file)
  in
  Memo.parallel_map modules ~f:(fun m ->
    compile_external_module sctx ~lib ~odoc_of_module m)
  >>| Path.Set.of_list_map ~f:Path.build
  >>= Dep.setup_deps ctx (Ext_lib lib)
;;

(* The installed libraries of an external package (excluding vlib impls). *)
let external_package_libs sctx pkg =
  let+ pkg_discovery = Package_discovery.create ~context:(Super_context.context sctx) in
  Package_discovery.libraries_of_package pkg_discovery pkg
;;

(* Compile an installed [.mld] page (its source lives in the install
   directory). Quiet, like external module compilation. *)
let compile_external_mld sctx ~pkg ~doc_dir ~src ~name =
  let ctx = Super_context.context sctx in
  let odoc_file = doc_dir ++ Printf.sprintf "page-%s.odoc" name in
  let run_odoc =
    run_odoc
      sctx
      ~dir:(Path.build doc_dir)
      "compile"
      ~quiet:true
      ~flags_for:None
      [ A "--output-dir"
      ; Path (Path.build (Paths.odoc_root ctx))
      ; As [ "--parent-id"; Package.Name.to_string pkg ]
      ; Hidden_targets [ odoc_file ]
      ; Dep src
      ]
  in
  let+ () = add_rule sctx run_odoc in
  odoc_file
;;

(* Compile an external package's documentation pages: its installed [.mld]
   pages, plus a generated [index] (listing the package's documented modules)
   if it ships none. *)
let setup_ext_pkg_odoc_rules sctx ~pkg ~libs =
  let ctx = Super_context.context sctx in
  let doc_dir = Paths.odocs ctx (Ext_pkg pkg) in
  let* pkg_discovery = Package_discovery.create ~context:ctx in
  let* mlds = Package_discovery.mlds_of_package pkg_discovery pkg in
  let* installed_odocs =
    Memo.parallel_map mlds ~f:(fun (src, name) ->
      compile_external_mld sctx ~pkg ~doc_dir ~src ~name)
  in
  let* index_odoc =
    if List.exists mlds ~f:(fun (_, name) -> String.equal name "index")
    then Memo.return []
    else
      let* modules =
        Memo.List.concat_map libs ~f:(fun lib ->
          Odoc_discovery.external_lib_modules sctx lib
          >>| List.map ~f:(fun (m : Odoc_discovery.ext_module) -> m.name))
      in
      let gen_mld = doc_dir ++ "index.mld" in
      let* () =
        add_rule
          sctx
          (Action_builder.write_file
             gen_mld
             (Odoc_discovery.external_default_index ~pkg ~modules))
      in
      let+ odoc =
        compile_mld
          sctx
          (Odoc_discovery.Mld.create ~path:gen_mld ~name:"index")
          ~pkg
          ~doc_dir
          ~includes:(Action_builder.return [])
      in
      [ odoc ]
  in
  Path.Set.of_list_map (installed_odocs @ index_odoc) ~f:Path.build
  |> Dep.setup_deps ctx (Ext_pkg pkg)
;;

(* Ask odoc to classify the install directory of an external library into
   ["<archive> <Mod> ..."] lines; the result drives external module discovery. *)
let setup_classify_rule sctx (lib : Lib.t) =
  let ctx = Super_context.context sctx in
  let src_dir = Lib_info.src_dir (Lib.info lib) in
  let program = odoc_program sctx (Context.build_dir ctx) in
  add_rule
    sctx
    (Command.run_dyn_prog
       program
       ~dir:(Path.build (Context.build_dir ctx))
       ~stdout_to:(Paths.classify_file ctx lib)
       [ A "classify"; A (Path.to_string src_dir) ])
;;

(* Generate one artifact in one output format. Returns the html/json directory
   target for module artifacts (whose output is a directory tree), and [None]
   for mld pages and markdown (which produce single files). *)
let setup_generate sctx ~mode ~search_db odoc_file out =
  let ctx = Super_context.context sctx in
  let odoc_support_path = Paths.odoc_support ctx ~mode in
  let output_file = Artifact.output_file ctx ~mode out odoc_file in
  let command, output_dir, args =
    match out with
    | Output_format.Markdown ->
      ( "markdown-generate"
      , Paths.markdown_root ctx
      , [ Command.Args.A "-o"
        ; Command.Args.Path (Path.build (Paths.markdown_root ctx))
        ; Command.Args.Dep (Path.build (Artifact.odocl_file ctx odoc_file))
        ] )
    | Html | Json ->
      let output_root =
        match out with
        | Json -> Paths.json_root ctx ~mode
        | Html | Markdown -> Paths.html_root ctx ~mode
      in
      let search_args =
        match search_db with
        | None -> Command.Args.empty
        | Some search_db ->
          Sherlodoc.odoc_args
            sctx
            ~search_db
            ~dir_sherlodoc_dot_js:(Paths.html_root ctx ~mode)
      in
      ( "html-generate"
      , output_root
      , [ search_args
        ; Command.Args.A "-o"
        ; Command.Args.Path (Path.build output_root)
        ; Command.Args.A "--support-uri"
        ; Command.Args.Path (Path.build odoc_support_path)
        ; Command.Args.A "--theme-uri"
        ; Command.Args.Path (Path.build odoc_support_path)
        ; Command.Args.Dep (Path.build (Artifact.odocl_file ctx odoc_file))
        ; Output_format.args out
        ] )
  in
  let run_odoc =
    run_odoc sctx ~dir:(Path.build output_dir) command ~quiet:false ~flags_for:None args
  in
  match out with
  | (Html | Json) when Artifact.is_module odoc_file ->
    let dir = Path.Build.parent_exn output_file in
    let+ () =
      add_rule
        sctx
        (Action_builder.With_targets.add_directories ~directory_targets:[ dir ] run_odoc)
    in
    Some dir
  | Html | Json | Markdown ->
    let+ () =
      add_rule
        sctx
        (Action_builder.With_targets.add run_odoc ~file_targets:[ output_file ])
    in
    None
;;

let setup_generate_markdown sctx odoc_file =
  let+ (_ : Path.Build.t option) =
    setup_generate sctx ~mode:Local_only ~search_db:None odoc_file Markdown
  in
  ()
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

let setup_css_rule sctx ~mode =
  setup_support_files_rule
    sctx
    ~dir:(Paths.odoc_support (Super_context.context sctx) ~mode)
;;

let stdlib_lib_name = Lib_name.of_string "stdlib"

(* External (installed) libraries documented in [Full] mode: the non-stdlib
   external members of every local package's dependency closure, grouped by
   their package. *)
let documented_external_pkgs sctx =
  let ctx = Super_context.context sctx in
  let* packages = Dune_load.packages () in
  let+ libs =
    Package.Name.Map.keys packages
    |> Memo.List.concat_map ~f:(fun pkg ->
      let* local = Odoc_discovery.libs_of_pkg (Context.name ctx) ~pkg in
      Lib.closure
        (List.map local ~f:Lib.Local.to_lib)
        ~linking:false
        ~for_:Compilation_mode.Ocaml
      >>= Resolve.read_memo
      >>| List.filter ~f:(fun lib ->
        Option.is_none (Lib.Local.of_lib lib)
        && not (Lib_name.equal (Lib.name lib) stdlib_lib_name)))
  in
  List.filter_map libs ~f:(fun lib -> Lib_info.package (Lib.info lib))
  |> Package.Name.Set.of_list
  |> Package.Name.Set.to_list
;;

let setup_toplevel_index_rule sctx ~mode output =
  let ctx = Super_context.context sctx in
  let* packages = Dune_load.packages () in
  let local_items = Odoc_discovery.Toplevel_index.of_packages packages output in
  let* external_items =
    match (mode : Doc_mode.t), (output : Output_format.t) with
    | Full, (Html | Json) ->
      let* pkg_discovery = Package_discovery.create ~context:ctx in
      let* ext_pkgs = documented_external_pkgs sctx in
      Memo.List.map ext_pkgs ~f:(fun pkg ->
        let+ version = Package_discovery.version_of_package pkg_discovery pkg in
        let name = Package.Name.to_string pkg in
        Odoc_discovery.Toplevel_index.external_item
          ~name
          ~version
          ~link:(sprintf "%s/index.html" name))
    | (Full | Local_only), _ -> Memo.return []
  in
  let content =
    Odoc_discovery.Toplevel_index.content output (local_items @ external_items)
  in
  let path = Output_format.toplevel_index_path ~mode output ctx in
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

(* The documentation targets of the libraries [requires] links against. Unlike
   the local-only flags used for local libraries, external dependencies are
   kept (as [Ext_lib]); [stdlib] is dropped since dune does not document it. *)
let link_requires_targets requires =
  let open Resolve.O in
  let+ libs = requires in
  List.filter_map libs ~f:(fun lib ->
    if Lib_name.equal (Lib.name lib) stdlib_lib_name
    then None
    else (
      match Lib.Local.of_lib lib with
      | Some l -> Some (Lib l)
      | None -> Some (Ext_lib lib)))
;;

(* Link an external library's [.odoc] into [.odocl], resolving cross-references
   against the odoc directories of its (local and external) dependencies. *)
let link_ext_odoc_rules sctx (odoc_file : Artifact.t) ~requires =
  let ctx = Super_context.context sctx in
  let targets = link_requires_targets requires in
  let include_flags =
    Resolve.args
      (let open Resolve.O in
       let+ targets = targets in
       Command.Args.S
         (List.concat_map targets ~f:(fun t ->
            [ Command.Args.A "-I"; Path (Path.build (Paths.odocs ctx t)) ])))
  in
  let deps =
    let open Action_builder.O in
    let* targets = Resolve.read targets in
    Action_builder.deps
      (Dune_engine.Dep.Set.of_list_map targets ~f:(fun t ->
         Dune_engine.Dep.alias (Dep.all_alias ctx t)))
  in
  let dir = Path.build (Path.Build.parent_exn (Artifact.odocl_file ctx odoc_file)) in
  let run_odoc =
    run_odoc
      sctx
      ~dir
      "link"
      ~quiet:true
      ~flags_for:None
      [ include_flags
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

let setup_ext_lib_odocl_rules sctx (lib : Lib.t) =
  let for_ = (Compilation_mode.of_mode_set (Lib_info.modes (Lib.info lib))).for_merlin in
  let* requires = Lib.closure [ lib ] ~linking:false ~for_ in
  let* odocs = Odoc_discovery.odoc_artefacts sctx (Ext_lib lib) in
  Memo.parallel_iter odocs ~f:(fun odoc -> link_ext_odoc_rules sctx ~requires odoc)
;;

(* Link the external package's [index] page, resolving its module references
   against the package's libraries. *)
let setup_ext_pkg_odocl_rules sctx ~pkg ~libs =
  let* requires = Lib.closure libs ~linking:false ~for_:Compilation_mode.Ocaml in
  let* odocs = Odoc_discovery.odoc_artefacts sctx (Ext_pkg pkg) in
  Memo.parallel_iter odocs ~f:(fun odoc -> link_ext_odoc_rules sctx ~requires odoc)
;;

(* Link the module [.odocl] of one local library. The link dependencies are the
   library's transitive closure plus, for a packaged library, its sibling
   libraries in the same package: this lets documentation cross-reference
   sibling modules even without a compile-time dependency. *)
let setup_local_lib_odocl_rules sctx (local : Lib.Local.t) =
  let ctx = Super_context.context sctx in
  let for_ =
    (Compilation_mode.of_mode_set (Lib_info.modes (Lib.Local.info local))).for_merlin
  in
  let* closure = Lib.closure [ Lib.Local.to_lib local ] ~linking:false ~for_ in
  let* requires =
    match Lib_info.package (Lib.Local.info local) with
    | None -> Memo.return closure
    | Some pkg ->
      let+ siblings = Odoc_discovery.libs_of_pkg (Context.name ctx) ~pkg in
      Resolve.map closure ~f:(fun libs -> libs @ List.map siblings ~f:Lib.Local.to_lib)
  in
  setup_lib_odocl_rules sctx local ~requires
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
  (* Only the package's own mld pages live in [_odocls/<pkg>]; each library's
     module [.odocl] files live in its own [_odocls/<lib-unique-name>] directory
     and are set up via the per-library dispatcher case. *)
  let f (sctx, pkg, for_) =
    let* requires =
      let* libs =
        Super_context.context sctx |> Context.name |> Odoc_discovery.libs_of_pkg ~pkg
      in
      Lib.closure (libs :> Lib.t list) ~linking:false ~for_
    in
    let* pkg_odocs = Odoc_discovery.odoc_artefacts sctx (Pkg pkg) in
    Memo.parallel_iter pkg_odocs ~f:(fun odoc ->
      link_odoc_rules sctx ~pkg:(Some pkg) ~requires odoc)
  in
  setup_pkg_rules_def "setup-package-odocls-rules" f
;;

let setup_pkg_odocl_rules sctx ~pkg ~for_ : unit Memo.t =
  Memo.With_implicit_output.exec setup_pkg_odocl_rules_def (sctx, pkg, for_)
;;

let out_file ctx ~mode (output : Output_format.t) odoc =
  Artifact.output_file ctx ~mode output odoc
;;

let out_files ctx ~mode (output : Output_format.t) odocs =
  let extra_files =
    match output with
    | Html -> [ Path.build (Paths.odoc_support ctx ~mode) ]
    | Json -> []
    | Markdown -> []
  in
  Path.build (Output_format.toplevel_index_path ~mode output ctx)
  :: List.rev_append
       extra_files
       (List.map odocs ~f:(fun odoc -> Path.build (out_file ctx ~mode output odoc)))
;;

let add_format_alias_deps ctx ~mode format target odocs =
  match (format : Output_format.t) with
  | Markdown ->
    (* skip alias deps for markdown since package directories are directory targets *)
    Memo.return ()
  | Html | Json ->
    let paths = out_files ctx ~mode format odocs in
    Rules.Produce.Alias.add_deps
      (Dep.format_alias ~mode format ctx target)
      (Action_builder.paths paths)
;;

(* A single search database, at the html root, indexing every documented
   artifact in the workspace. Its rule is added under the [_html] node; other
   nodes reference its path via [Sherlodoc.search_db_path]. *)
let setup_global_search_db sctx ~mode =
  let ctx = Super_context.context sctx in
  let* libs = Odoc_discovery.all_local_libs sctx in
  let* packages = Dune_load.packages () in
  let targets =
    List.map (Package.Name.Map.keys packages) ~f:(fun p -> Pkg p)
    @ List.map libs ~f:(fun l -> Lib l)
  in
  let* odocls =
    Memo.List.concat_map targets ~f:(fun target ->
      let+ odocs = Odoc_discovery.odoc_artefacts sctx target in
      List.map odocs ~f:(Artifact.odocl_file ctx))
  in
  let+ (_ : Path.Build.t) =
    Sherlodoc.search_db sctx ~dir:(Paths.html_root ctx ~mode) ~external_odocls:[] odocls
  in
  ()
;;

(* Generate one output format for a documentation target: run odoc for each of
   its artifacts and register the format's alias dependencies. Returns the
   per-module directory targets produced. *)
let setup_target_format_rules sctx ~mode ~format target =
  let ctx = Super_context.context sctx in
  let search_db = Sherlodoc.search_db_path ~dir:(Paths.html_root ctx ~mode) in
  let* odocs = Odoc_discovery.odoc_artefacts sctx target in
  let* dirs =
    Memo.parallel_map odocs ~f:(fun odoc ->
      setup_generate sctx ~mode ~search_db:(Some search_db) odoc format)
  in
  let+ () = add_format_alias_deps ctx ~mode format target odocs in
  List.filter_opt dirs
;;

(* An external package's [_doc/_<tree>/<pkg>] directory holds its generated
   index page and, in [<lib>] subdirectories, every library of the package. *)
let setup_ext_pkg_compile sctx ~pkg ~libs =
  let* () = Memo.parallel_iter libs ~f:(setup_external_lib_odoc_rules sctx) in
  setup_ext_pkg_odoc_rules sctx ~pkg ~libs
;;

let setup_ext_pkg_link sctx ~pkg ~libs =
  let* () = Memo.parallel_iter libs ~f:(setup_ext_lib_odocl_rules sctx) in
  setup_ext_pkg_odocl_rules sctx ~pkg ~libs
;;

let setup_ext_pkg_format_rules sctx ~mode ~format ~pkg ~libs =
  let* lib_dirs =
    Memo.parallel_map libs ~f:(fun lib ->
      setup_target_format_rules sctx ~mode ~format (Ext_lib lib))
  in
  let+ pkg_dirs = setup_target_format_rules sctx ~mode ~format (Ext_pkg pkg) in
  List.concat (pkg_dirs :: lib_dirs)
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
  >>= add_format_alias_deps ctx ~mode:Local_only Markdown target
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
  add_format_alias_deps ctx ~mode:Local_only Markdown (Pkg pkg) all_odocs
;;

let setup_package_aliases_format sctx (pkg : Package.t) (output : Output_format.t) =
  let ctx = Super_context.context sctx in
  let name = Package.name pkg in
  let alias_dir =
    let pkg_dir = Package.dir pkg in
    Path.Build.append_source (Context.build_dir ctx) pkg_dir
  in
  let deps_for ~(mode : Doc_mode.t) =
    match (output : Output_format.t) with
    | Markdown ->
      (* markdown has no [_markdown_full] tree yet; the full alias mirrors local *)
      let directory_target = Paths.markdown ctx (Pkg name) in
      let toplevel_index = Paths.markdown_index ctx in
      Memo.return
        (let open Action_builder.O in
         let+ () = Action_builder.path (Path.build directory_target)
         and+ () = Action_builder.path (Path.build toplevel_index) in
         ())
    | Html | Json ->
      let* local_libs = Context.name ctx |> Odoc_discovery.libs_of_pkg ~pkg:name in
      let local_targets = List.map local_libs ~f:(fun lib -> Lib lib) in
      (* In [Full] mode, also document the external (installed) libraries in the
         package's dependency closure (excluding [stdlib]) and the index pages of
         the packages they belong to. *)
      let+ external_targets =
        match mode with
        | Doc_mode.Local_only -> Memo.return []
        | Doc_mode.Full ->
          let+ closure =
            Lib.closure
              (List.map local_libs ~f:Lib.Local.to_lib)
              ~linking:false
              ~for_:Compilation_mode.Ocaml
            >>= Resolve.read_memo
          in
          let ext_libs =
            List.filter closure ~f:(fun lib ->
              Option.is_none (Lib.Local.of_lib lib)
              && not (Lib_name.equal (Lib.name lib) stdlib_lib_name))
          in
          let ext_pkgs =
            List.filter_map ext_libs ~f:(fun lib -> Lib_info.package (Lib.info lib))
            |> Package.Name.Set.of_list
            |> Package.Name.Set.to_list
          in
          List.map ext_libs ~f:(fun lib -> Ext_lib lib)
          @ List.map ext_pkgs ~f:(fun pkg -> Ext_pkg pkg)
      in
      (Pkg name :: local_targets) @ external_targets
      |> List.map ~f:(Dep.format_alias ~mode output ctx)
      |> Dune_engine.Dep.Set.of_list_map ~f:(fun f -> Dune_engine.Dep.alias f)
      |> Action_builder.deps
  in
  let register mode =
    let* deps = deps_for ~mode in
    Rules.Produce.Alias.add_deps (Output_format.alias output ~mode ~dir:alias_dir) deps
  in
  let* () = register Local_only in
  register Full
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
      (lib
       |> Dep.format_alias ~mode:Local_only Html ctx
       |> Dune_engine.Dep.alias
       |> Action_builder.dep)
;;

let has_rules ?(directory_targets = Path.Build.Map.empty) m =
  let rules = Rules.collect_unit (fun () -> m) in
  Memo.return (Gen_rules.make ~directory_targets rules)
;;

(* Like [has_rules] but the action [m] returns the directory targets it produces
   (e.g. per-module html dirs), which are collected and declared. [extra] are
   additional directory targets (such as the odoc support files). *)
let has_rules_with_dir_targets ?(extra = []) m =
  let* dirs, rules = Rules.collect (fun () -> m) in
  let directory_targets =
    List.rev_append extra dirs
    |> Path.Build.Map.of_list_map_exn ~f:(fun dir -> dir, Loc.none)
  in
  Memo.return (Gen_rules.make ~directory_targets (Memo.return rules))
;;

(* Generate one output format for a single output directory [_<fmt>/<name>],
   where [name] resolves to a library and/or a package (they share a directory
   when a library's unique name equals its package name). *)
let output_artifacts sctx ~mode ~format pkg_or_lib_name =
  has_rules_with_dir_targets
    (let ctx = Super_context.context sctx in
     let* packages = Dune_load.packages () in
     match Package.Name.Map.find packages (Package.Name.of_string pkg_or_lib_name) with
     | Some pkg ->
       (* The package directory [_<fmt>/<pkg>] holds the package's mld pages and,
          in subdirectories [<lib>], every library of the package. *)
       let pkg_name = Package.name pkg in
       let* libs = Odoc_discovery.libs_of_pkg (Context.name ctx) ~pkg:pkg_name in
       let* lib_dirs =
         Memo.parallel_map libs ~f:(fun lib ->
           setup_target_format_rules sctx ~mode ~format (Lib lib))
       in
       let+ pkg_dirs = setup_target_format_rules sctx ~mode ~format (Pkg pkg_name) in
       List.concat (pkg_dirs :: lib_dirs)
     | None ->
       (* An external package (documented only in [Full]) or a private library. *)
       let pkg = Package.Name.of_string pkg_or_lib_name in
       let* ext_libs =
         match (mode : Doc_mode.t) with
         | Local_only -> Memo.return []
         | Full -> external_package_libs sctx pkg
       in
       (match ext_libs with
        | _ :: _ -> setup_ext_pkg_format_rules sctx ~mode ~format ~pkg ~libs:ext_libs
        | [] ->
          let* name, lib_db =
            Odoc_scope.Scope_key.of_string (Context.name ctx) pkg_or_lib_name
          in
          let* lib = Lib.DB.find lib_db name in
          (match lib with
           | None -> Memo.return []
           | Some lib ->
             (match Lib.Local.of_lib lib with
              | Some local -> setup_target_format_rules sctx ~mode ~format (Lib local)
              | None ->
                (match (mode : Doc_mode.t) with
                 | Local_only -> Memo.return []
                 | Full -> setup_target_format_rules sctx ~mode ~format (Ext_lib lib))))))
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
  | [ ("_html" | "_html_full") ] ->
    let mode : Doc_mode.t = if rest = [ "_html_full" ] then Full else Local_only in
    let ctx = Super_context.context sctx in
    let directory_targets =
      Path.Build.Map.singleton (Paths.odoc_support ctx ~mode) Loc.none
    in
    has_rules
      ~directory_targets
      (Sherlodoc.sherlodoc_dot_js sctx ~dir:(Paths.html_root ctx ~mode)
       >>> setup_css_rule sctx ~mode
       >>> setup_global_search_db sctx ~mode
       >>> setup_toplevel_index_rule sctx ~mode Html)
  | [ "_html"; pkg_or_lib_name ] ->
    output_artifacts sctx ~mode:Local_only ~format:Html pkg_or_lib_name
  | [ "_html_full"; pkg_or_lib_name ] ->
    output_artifacts sctx ~mode:Full ~format:Html pkg_or_lib_name
  | [ "_json" ] -> has_rules (setup_toplevel_index_rule sctx ~mode:Local_only Json)
  | [ "_json_full" ] -> has_rules (setup_toplevel_index_rule sctx ~mode:Full Json)
  | [ "_json"; pkg_or_lib_name ] ->
    output_artifacts sctx ~mode:Local_only ~format:Json pkg_or_lib_name
  | [ "_json_full"; pkg_or_lib_name ] ->
    output_artifacts sctx ~mode:Full ~format:Json pkg_or_lib_name
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
      (let* () = setup_toplevel_index_rule sctx ~mode:Local_only Markdown in
       Package.Name.Map.to_seq packages
       |> Memo.parallel_iter_seq ~f:(fun (_, (pkg : Package.t)) ->
         let pkg_name = Package.name pkg in
         setup_pkg_markdown_rules sctx ~pkg:pkg_name))
  | [ "_markdown"; _lib_unique_name_or_pkg ] ->
    (* package directories are directory targets *)
    Memo.return Gen_rules.no_rules
  | [ "_classify"; lib_name ] ->
    has_rules
      (let ctx = Super_context.context sctx in
       let* name, lib_db = Odoc_scope.Scope_key.of_string (Context.name ctx) lib_name in
       let* lib = Lib.DB.find lib_db name in
       match lib with
       | None -> Memo.return ()
       | Some lib ->
         (match Lib.Local.of_lib lib with
          | Some _ -> Memo.return ()
          | None -> setup_classify_rule sctx lib))
  | [ "_mlds"; pkg ] ->
    with_package pkg ~f:(fun pkg ->
      let pkg = Package.name pkg in
      let* _mlds, rules = package_mlds sctx ~pkg in
      Rules.produce rules)
  | [ "_odoc"; name ] ->
    has_rules
      ((* A package's mld pages are compiled into [_doc/_odoc/<pkg>] and each of
          its libraries' modules into the subdirectory [_doc/_odoc/<pkg>/<lib>].
          A private library uses its own [_doc/_odoc/<lib-unique-name>]. *)
       let ctx = Super_context.context sctx in
       let* packages = Dune_load.packages () in
       match Package.Name.Map.find packages (Package.Name.of_string name) with
       | Some pkg ->
         let pkg_name = Package.name pkg in
         let* libs = Odoc_discovery.libs_of_pkg (Context.name ctx) ~pkg:pkg_name in
         let* () = Memo.parallel_iter libs ~f:(setup_library_odoc_rules sctx) in
         setup_package_odoc_rules sctx ~pkg:pkg_name
       | None ->
         let pkg = Package.Name.of_string name in
         let* ext_libs = external_package_libs sctx pkg in
         (match ext_libs with
          | _ :: _ -> setup_ext_pkg_compile sctx ~pkg ~libs:ext_libs
          | [] ->
            let* lib_name, lib_db =
              Odoc_scope.Scope_key.of_string (Context.name ctx) name
            in
            let* lib = Lib.DB.find lib_db lib_name in
            (match lib with
             | None -> Memo.return ()
             | Some lib ->
               (match Lib.Local.of_lib lib with
                | Some local -> setup_library_odoc_rules sctx local
                | None -> setup_external_lib_odoc_rules sctx lib))))
  | [ "_odocls"; name ] ->
    has_rules
      ((* A package's mld [.odocl] live in [_odocls/<pkg>] and each library's
          module [.odocl] in the subdirectory [_odocls/<pkg>/<lib>]. A private
          library uses its own [_odocls/<lib-unique-name>]. *)
       let ctx = Super_context.context sctx in
       let* packages = Dune_load.packages () in
       match Package.Name.Map.find packages (Package.Name.of_string name) with
       | Some pkg ->
         let pkg_name = Package.name pkg in
         let* libs = Odoc_discovery.libs_of_pkg (Context.name ctx) ~pkg:pkg_name in
         let* () = Memo.parallel_iter libs ~f:(setup_local_lib_odocl_rules sctx) in
         setup_pkg_odocl_rules sctx ~pkg:pkg_name ~for_:Compilation_mode.Ocaml
       | None ->
         let pkg = Package.Name.of_string name in
         let* ext_libs = external_package_libs sctx pkg in
         (match ext_libs with
          | _ :: _ -> setup_ext_pkg_link sctx ~pkg ~libs:ext_libs
          | [] ->
            let* lib_name, lib_db =
              Odoc_scope.Scope_key.of_string (Context.name ctx) name
            in
            let* lib = Lib.DB.find lib_db lib_name in
            (match lib with
             | None -> Memo.return ()
             | Some lib ->
               (match Lib.Local.of_lib lib with
                | Some local -> setup_local_lib_odocl_rules sctx local
                | None -> setup_ext_lib_odocl_rules sctx lib))))
  | _ -> Memo.return (Gen_rules.redirect_to_parent Gen_rules.Rules.empty)
;;
