`mylib` is a local package whose library depends on the external `unix`
library.

In the default (local-only) `@doc`, only the local library is documented:

  $ dune build @doc 2>/dev/null
  $ ls _build/default/_doc/_html/mylib
  index.html
  mylib
  $ test -f _build/default/_doc/_html/mylib/mylib/Mylib/index.html && echo ok
  ok

There is no documentation for external libraries in the local-only tree:

  $ test -d _build/default/_doc/_html/unix && echo "present" || echo "absent"
  absent

`@doc-full` (Doc_mode.Full) additionally documents the external libraries in the
dependency closure, into the `_html_full` tree. odoc emits version-specific
warnings about `unix.mli`, so we discard stderr.

Both local and external libraries nest under their package (`<pkg>/<lib>`); the
external `unix` library's findlib package is also called `unix`.

  $ dune build @doc-full 2>/dev/null
  $ test -f _build/default/_doc/_html_full/mylib/mylib/Mylib/index.html && echo ok
  ok
  $ test -f _build/default/_doc/_html_full/unix/unix/Unix/index.html && echo ok
  ok
  $ test -f _build/default/_doc/_html_full/unix/unix/UnixLabels/index.html && echo ok
  ok

The Full toplevel index lists `unix` as an external package, linking to one of
its documented modules (its version span is rendered too, but omitted here as
it is specific to the installed OCaml):

  $ grep -o '<a href="unix/[^"]*">unix</a>' \
  >   _build/default/_doc/_html_full/index.html
  <a href="unix/index.html">unix</a>

That link resolves to the external package's generated index page:

  $ test -f _build/default/_doc/_html_full/unix/index.html && echo ok
  ok

The local-only index does not mention external packages:

  $ grep -c unix _build/default/_doc/_html/index.html
  0
  [1]

The external library's `.odoc`/`.odocl` are produced under `<pkg>/<lib>`:

  $ find _build/default/_doc/_odoc/unix _build/default/_doc/_odocls/unix \
  >   \( -name '*.odoc' -o -name '*.odocl' \) | sort
  _build/default/_doc/_odoc/unix/page-index.odoc
  _build/default/_doc/_odoc/unix/unix/unix.odoc
  _build/default/_doc/_odoc/unix/unix/unixLabels.odoc
  _build/default/_doc/_odocls/unix/page-index.odocl
  _build/default/_doc/_odocls/unix/unix/unix.odocl
  _build/default/_doc/_odocls/unix/unix/unixLabels.odocl
