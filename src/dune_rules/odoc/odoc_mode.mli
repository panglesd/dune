(** Documentation coverage mode.

    [Local_only] documents only the workspace's own libraries (the [@doc]
    aliases). [Full] additionally documents their external/installed/stdlib
    dependencies (the [@doc-all] aliases). The two are generated into separate
    output trees (e.g. [_doc/_html] vs [_doc/_html_full]). *)
type t =
  | Local_only
  | Full
