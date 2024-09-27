module Index_tree : sig
  type artifact_info =
    { artifacts : Doc_artifact.t list
    ; compile_libs : Lib.t list
    }

  type info =
    { artifact_sets : artifact_info list
    ; predefined_index : Stdune.Path.t option
    ; libs : Doc_artifact.t list Lib.Map.t
    ; package : Dune_lang.Package_name.t option
    ; is_fallback : bool
    }

  val all_artifacts : info -> Doc_artifact.t list
end

val ext_package_mlds : Context.t -> Dune_lang.Package_name.t -> Stdune.Path.t list Memo.t
val pkg_mlds : Super_context.t -> Dune_lang.Package_name.t -> Stdune.Path.t list Memo.t

val check_mlds_no_dupes
  :  pkg:Dune_lang.Package_name.t
  -> mlds:Stdune.Path.t list
  -> Stdune.Path.t Import.String.Map.t

val pkg_artifacts
  :  Super_context.t
  -> Doc_index.Index.t
  -> Dune_lang.Package_name.t
  -> (Stdune.Path.t option * Doc_artifact.t list) Memo.t

val index_info_of_pkg_def
  : ( Super_context.t * bool * Dune_lang.Package_name.t
      , (Doc_index.Index.t * Index_tree.info) list )
      Memo.Table.t

val index_info_of_pkg
  :  Super_context.t
  -> bool
  -> Dune_lang.Package_name.t
  -> (Doc_index.Index.t * Index_tree.info) list Memo.t
