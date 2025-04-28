open Import

type qualification =
  | Unqualified
  | Qualified
  | As_manual

type t =
  | No
  | Include of qualification

type stanza = Loc.t * t

include Stanza.Make (struct
    type nonrec t = stanza

    include Poly
  end)

let decode ~enable_qualified ~enable_documentation =
  let open Dune_lang.Decoder in
  sum
    [ "no", return No
    ; "unqualified", return (Include Unqualified)
    ; ( "qualified"
      , let+ () =
          if enable_qualified then return () else Syntax.since Stanza.syntax (3, 7)
        in
        Include Qualified )
    ; ( "as_documentation"
      , let+ () =
          if enable_documentation then return () else Syntax.since Stanza.syntax (3, 18)
        in
        Include As_manual )
    ]
;;
