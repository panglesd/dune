open Import
open Memo.O

type t = { findlib : Findlib.t }

let create ~context =
  let+ findlib = Findlib.create (Context.name context) in
  { findlib }
;;

let version_of_package t pkg =
  Findlib.find_root_package t.findlib pkg
  >>| function
  | Error _ -> None
  | Ok (dpkg : Dune_package.t) -> Option.map dpkg.version ~f:Package_version.to_string
;;
