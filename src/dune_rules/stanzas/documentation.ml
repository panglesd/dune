open Import

type t =
  { loc : Loc.t
  ; package : Package.t
  ; mld_files : Ordered_set_lang.t
  ; path : string
  ; files : Install_entry.File.t list
  ; source_trees : Install_entry.Dir.t list
  }

include Stanza.Make (struct
    type nonrec t = t

    include Poly
  end)

let decode =
  let open Dune_lang.Decoder in
  fields
    (let+ package = Stanza_common.Pkg.field ~stanza:"documentation"
     and+ mld_files = Ordered_set_lang.field "mld_files"
     and+ path = field_o "path" string
     and+ files = field_o "files" (repeat Install_entry.File.decode)
     and+ source_trees = field_o "source_trees" (repeat Install_entry.Dir.decode)
     and+ loc = loc in
     let path = Option.value ~default:"" path
     and files = Option.value files ~default:[]
     and source_trees = Option.value source_trees ~default:[] in
     { loc; package; mld_files; path; files; source_trees })
;;
