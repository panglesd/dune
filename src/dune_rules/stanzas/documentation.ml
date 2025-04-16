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

include Stanza.Make (struct
    type nonrec t = t

    include Poly
  end)

let decode =
  let open Dune_lang.Decoder in
  fields
    (let+ package = Stanza_common.Pkg.field ~stanza:"documentation"
     and+ mld_files = Ordered_set_lang.field "mld_files"
     and+ path = field "path" string
     and+ files = field_o "files" (repeat Install_entry.File.decode)
     and+ dirs = field_o "dirs" (repeat Install_entry.Dir.decode)
     and+ source_trees = field_o "source_trees" (repeat Install_entry.Dir.decode)
     and+ loc = loc in
     let files, dirs, source_trees =
       match files, dirs, source_trees with
       | None, None, None ->
         User_error.raise ~loc [ Pp.textf "dirs, files, or source_trees must be set" ]
       | _, _, _ ->
         ( Option.value files ~default:[]
         , Option.value dirs ~default:[]
         , Option.value source_trees ~default:[] )
     in
     { loc; package; mld_files; path; files; dirs; source_trees })
;;
