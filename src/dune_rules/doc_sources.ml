open Import
open Memo.O

type mld =
  { path : Path.Build.t
  ; parent_id : string list
  }

let rec rem_prefix l1 l2 =
  match l1, l2 with
  | [], l2 -> l2
  | _, [] -> assert false
  | x :: l1, y :: l2 ->
    assert (x = y);
    rem_prefix l1 l2
;;

let rec remove_tail acc = function
  | [] | [ _ ] -> List.rev acc
  | h :: t -> remove_tail (h :: acc) t
;;

let of_file_bindings parent_id_prefix dir fbs =
  List.map fbs ~f:(fun file_binding ->
    let path = File_binding.Expanded.src file_binding in
    let parent_id =
      match File_binding.Expanded.dst file_binding with
      | None ->
        rem_prefix
          (Path.Build.explode dir)
          (path |> Path.Build.parent_exn |> Path.Build.explode)
      | Some parent_id -> String.split_on_char ~sep:'/' parent_id |> remove_tail []
    in
    let parent_id = parent_id_prefix @ parent_id in
    Path.Build.Map.singleton path { path; parent_id })
;;

let from_mld_files mlds doc dir parent_id_prefix =
  let+ mlds =
    let+ mlds = Memo.Lazy.force mlds in
    Ordered_set_lang.Unordered_string.eval
      doc.Documentation.mld_files
      ~standard:mlds
      ~key:Fun.id
      ~parse:(fun ~loc s ->
        match Filename.Map.find mlds s with
        | Some s -> s
        | None ->
          User_error.raise
            ~loc
            [ Pp.textf
                "%s doesn't exist in %s"
                s
                (Path.to_string_maybe_quoted
                   (Path.drop_optional_build_context (Path.build dir)))
            ])
  in
  mlds
  |> Filename.Map.map ~f:(fun x ->
    let path = Path.Build.relative dir x in
    Path.Build.Map.singleton path { path; parent_id = parent_id_prefix })
  |> Filename.Map.values
;;

let build_mlds_map stanzas ~dir ~files expander =
  let mlds =
    Memo.lazy_ (fun () ->
      Filename.Set.fold files ~init:Filename.Map.empty ~f:(fun fn acc ->
        (* TODO this doesn't handle [.foo.mld] correctly *)
        match String.lsplit2 fn ~on:'.' with
        | Some (_, "mld") -> Filename.Map.set acc fn fn
        | _ -> acc)
      |> Memo.return)
  in
  Dune_file.find_stanzas stanzas Documentation.key
  >>= Memo.parallel_map ~f:(fun (doc : Documentation.t) ->
    let parent_id_prefix =
      if doc.path = "" then [] else String.split_on_char ~sep:'/' doc.path
    in
    let* from_mld_files = from_mld_files mlds doc dir parent_id_prefix in
    let+ from_files =
      let expand = Expander.No_deps.expand expander ~mode:Single in
      let+ file_bindings =
        Install_entry.File.to_file_bindings_expanded doc.files ~expand ~dir
      in
      of_file_bindings parent_id_prefix dir file_bindings
    in
    let mlds =
      Path.Build.Map.union_all
        ~f:(fun p v1 v2 ->
          if v1 = v2
          then Some v1
          else (
            let installed_as v =
              String.concat ~sep:"/" (v.parent_id @ [ Path.Build.basename v.path ])
            in
            User_error.raise
              ~loc:doc.loc
              [ Pp.textf
                  "%s is used in docs both as %s and as %s"
                  (Path.to_string_maybe_quoted
                     (Path.drop_optional_build_context (Path.build p)))
                  (installed_as v1)
                  (installed_as v2)
              ]))
        (List.concat [ from_mld_files; from_files ])
      |> Path.Build.Map.values
    in
    doc, mlds)
;;
