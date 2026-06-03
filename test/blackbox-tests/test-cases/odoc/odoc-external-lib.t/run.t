`mylib` is a local package whose library depends on the external `unix`
library.

In the default (local-only) `@doc`, only the local library is documented:

  $ dune build @doc 2>/dev/null
  $ ls _build/default/_doc/_html/mylib
  Mylib
  index.html

There is no documentation for external libraries in the local-only tree:

  $ test -d _build/default/_doc/_html/unix && echo "present" || echo "absent"
  absent

`@doc-all` (Doc_mode.Full) additionally documents the external libraries in the
dependency closure, into the `_html_full` tree. odoc emits version-specific
warnings about `unix.mli`, so we discard stderr.

  $ dune build @doc-all 2>/dev/null
  $ test -f _build/default/_doc/_html_full/mylib/Mylib/index.html && echo ok
  ok
  $ test -f _build/default/_doc/_html_full/unix/Unix/index.html && echo ok
  ok
  $ test -f _build/default/_doc/_html_full/unix/UnixLabels/index.html && echo ok
  ok

The external library's `.odoc`/`.odocl` are produced under its own name:

  $ find _build/default/_doc/_odoc/unix _build/default/_doc/_odocls/unix \
  >   \( -name '*.odoc' -o -name '*.odocl' \) | sort
  _build/default/_doc/_odoc/unix/unix.odoc
  _build/default/_doc/_odoc/unix/unixLabels.odoc
  _build/default/_doc/_odocls/unix/unix.odocl
  _build/default/_doc/_odocls/unix/unixLabels.odocl
