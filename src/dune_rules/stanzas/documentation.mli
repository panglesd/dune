open Import

type t =
  { loc : Loc.t
  ; package : Package.t
  ; mld_files : Ordered_set_lang.t
  ; path : string
  ; files : Install_entry.File.t list
  ; dirs : Install_entry.Dir.t list
  ; source_trees : Install_entry.Dir.t list
  }

include Stanza.S with type t := t

val decode : t Dune_lang.Decoder.t
