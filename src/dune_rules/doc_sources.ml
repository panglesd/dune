open Import
open Memo.O

type mld =
  { path : Path.Build.t
  ; in_doc : Path.Local.t
  }

let of_file_bindings parent_id_prefix fbs =
  List.map fbs ~f:(fun file_binding ->
    let path = File_binding.Expanded.src file_binding in
    let parent_id =
      match File_binding.Expanded.dst file_binding with
      | None -> Path.Local.of_string (Path.Build.basename path)
      | Some as_ ->
        let loc = File_binding.Expanded.src_loc file_binding in
        Path.Local.parse_string_exn ~loc as_
      (* Format.printf "Dst is Some %s%!\n" parent_id; *)
      (* String.split_on_char ~sep:'/' parent_id |> remove_tail [] *)
    in
    let in_doc = Path.Local.append parent_id_prefix parent_id in
    Path.Build.Map.singleton path { path; in_doc })
;;

let from_mld_files mlds doc dir parent_id_prefix =
  let+ mlds =
    let+ mlds = Memo.Lazy.force mlds in
    Ordered_set_lang.Unordered_string.eval
      doc.Documentation.mld_files
      ~standard:mlds
      ~key:Fun.id
      ~parse:(fun ~loc s ->
        match Filename.Map.find mlds (s ^ ".mld") with
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
    let in_doc = Path.Local.relative parent_id_prefix x in
    Path.Build.Map.singleton path { path; in_doc })
  |> Filename.Map.values
;;

(* let of_source_trees parent_id_prefix dir source_trees ~expander = *)
(*   let expand = Expander.No_deps.expand expander ~mode:Single in *)
(*   let* file_bindings = *)
(*     Install_entry.Dir.to_file_bindings_expanded *)
(*       source_trees *)
(*       ~expand *)
(*       ~dir *)
(*       ~relative_dst_path_starts_with_parent_error_when:`Always_error *)
(*   in *)
(*   let res = *)
(*     Memo.List.concat_map *)
(*       ~f:(fun (fb : File_binding.Expanded.t) -> *)
(*         let src_dir = File_binding.Expanded.src fb in *)
(*         let prefix_parent_id = *)
(*           match File_binding.Expanded.dst fb with *)
(*           | None -> parent_id_prefix @ [ Path.Build.basename src_dir ] *)
(*           | Some ("." | "") -> parent_id_prefix *)
(*           | Some dst -> *)
(*             let suffix = *)
(*               dst |> String.split_on_char ~sep:'/' |> List.filter ~f:(String.equal "") *)
(*             in *)
(*             parent_id_prefix @ suffix *)
(*         in *)
(*         let+ _, files = Source_deps.files (Path.build src_dir) in *)
(*         Path.Set.to_list_map files ~f:(fun src -> *)
(*           let suffix = Path.drop_prefix_exn ~prefix:(Path.build src_dir) src in *)
(*           let parent_id = *)
(*             prefix_parent_id @ (Path.Local.explode suffix |> remove_tail []) *)
(*           in *)
(*           let path = Path.as_in_build_dir_exn src in *)
(*           Path.Build.Map.singleton path { path; parent_id })) *)
(*       file_bindings *)
(*   in *)
(*   res *)
(* ;; *)

(* let symlink_source_dir ~dir = *)
(*   let+ _, files = Source_deps.files dir in *)
(*   Path.Set.to_list_map files ~f:(fun src -> Path.drop_prefix_exn ~prefix:dir src) *)
(* in *)
(* let do_ (entry : Path.Build.t Install.Entry.t) = *)
(*   let src = Path.build entry.src in *)
(*   let res = *)
(*     symlink_source_dir ~dir:src *)
(*     >>| List.map ~f:(fun suffix -> *)
(*       let entry = *)
(*         Install.Entry.map_dst entry ~f:(fun dst -> *)
(*           Install.Entry.Dst.add_suffix dst (Path.Local.to_string suffix)) *)
(*       in *)
(*       let entry = Install.Entry.set_src entry dst in *)
(*       Install.Entry.set_kind entry `File) *)
(*   in *)
(*   _ *)
(* in *)
(* of_file_bindings parent_id_prefix dir file_bindings *)

let of_files parent_id_prefix dir files ~expander =
  let expand = Expander.No_deps.expand expander ~mode:Single in
  let+ file_bindings = Install_entry.File.to_file_bindings_expanded files ~expand ~dir in
  of_file_bindings parent_id_prefix file_bindings
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
      (* if doc.path = "" then [] else String.split_on_char ~sep:'/' doc.path *)
      let loc = doc.loc in
      Path.Local.parse_string_exn ~loc doc.path
    in
    let* from_mld_files = from_mld_files mlds doc dir parent_id_prefix in
    let+ from_files = of_files parent_id_prefix dir doc.files ~expander in
    (* let+ from_source_trees = *)
    (*   of_source_trees parent_id_prefix dir doc.source_trees ~expander *)
    (* in *)
    let mlds =
      Path.Build.Map.union_all
        ~f:(fun p v1 v2 ->
          if v1 = v2
          then Some v1
          else (
            let installed_as v =
              Path.Local.to_string v.in_doc
              (* String.concat ~sep:"/" (v.parent_id @ [ Path.Build.basename v.path ]) *)
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
        (List.concat [ from_mld_files; from_files (* ; from_source_trees *) ])
      |> Path.Build.Map.values
    in
    doc, mlds)
;;
