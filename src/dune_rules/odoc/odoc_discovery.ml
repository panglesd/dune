open Import
open Memo.O

let libs_of_pkg ctx ~pkg =
  let+ { Scope.DB.Lib_entry.Set.libraries; _ } = Scope.DB.lib_entries_of_package ctx pkg in
  (* Filter out all implementations of virtual libraries *)
  List.filter_map libraries ~f:(fun lib ->
    match Lib.Local.to_lib lib |> Lib.info |> Lib_info.implements with
    | None -> Some lib
    | Some _ -> None)
;;

let entry_modules_by_lib sctx lib =
  let info = Lib.Local.info lib in
  let { Compilation_mode.for_merlin; _ } =
    Compilation_mode.of_mode_set (Lib_info.modes info)
  in
  Dir_contents.modules_of_local_lib sctx lib ~for_:for_merlin >>| Modules.entry_modules
;;

let entry_modules sctx ~pkg =
  let* l =
    Super_context.context sctx
    |> Context.name
    |> libs_of_pkg ~pkg
    >>| List.filter ~f:(fun lib ->
      Lib.Local.info lib |> Lib_info.status |> Lib_info.Status.is_private |> not)
  in
  let+ l =
    Memo.parallel_map l ~f:(fun l ->
      let+ m = entry_modules_by_lib sctx l in
      l, m)
  in
  Lib.Local.Map.of_list_exn l
;;
