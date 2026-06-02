open Import

(** A documentation file (mld or asset) with its path and location in doc hierarchy *)
type doc_file =
  { path : Path.Build.t (** The path to the file *)
  ; in_doc : Path.Local.t (** Where in the doc hierarchy the file should appear *)
  }

(** Mld documentation file *)
type mld = doc_file

(** Builds a map of [mld] files from the [(documentation ...)] stanza.
    Only includes files with .mld extension. *)
val build_mlds_map
  :  Dune_file.t
  -> dir:Path.Build.t
  -> files:Filename.Array.Set.t
  -> Expander.t
  -> (Documentation.t * mld list) list Memo.t
