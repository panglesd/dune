Test that documentation-only dependencies (not compilation dependencies) are
correctly handled. The library references {!Cmdliner.Arg.t} in doc comments
but does NOT have cmdliner in its (libraries ...) stanza.

Build documentation:

  $ dune build @doc
  File "domain.mli", line 69, character 4 to line 74, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "fun.mli", line 92, characters 3-8:
  Warning: 'const' is deprecated, use 'constructor' instead.
  File "scanf.mli", line 86, character 0 to line 88, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "array.mli", line 449, character 1 to line 455, character 2:
  Warning: Code blocks should be indented at the opening `{`.
  File "arrayLabels.mli", line 449, character 1 to line 455, character 2:
  Warning: Code blocks should be indented at the opening `{`.
  File "buffer.mli", line 35, character 0 to line 37, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "bytes.mli", line 368, character 3 to line 373, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytes.mli", line 395, character 3 to line 398, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytes.mli", line 432, character 4 to line 435, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytesLabels.mli", line 368, character 3 to line 373, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytesLabels.mli", line 395, character 3 to line 398, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytesLabels.mli", line 432, character 4 to line 435, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "dynarray.mli", line 47, character 0 to line 49, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "hashtbl.mli", line 47, character 0 to line 49, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "queue.mli", line 24, character 0 to line 26, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "stack.mli", line 23, character 0 to line 25, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "format.mli", line 363, character 3 to line 369, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "format.mli", line 372, character 3 to line 375, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "format.mli", line 1575, character 2 to line 1579, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "ephemeron.mli", line 70, character 0 to line 72, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "moreLabels.mli", line 64, character 2 to line 66, character 3:
  Warning: Alert unsynchronized_access not expected here.
  File "gc.mli", line 431, character 3 to line 440, character 5:
  Warning: Code blocks should be indented at the opening `{`.

Check that documentation was generated:

  $ ls _build/default/_doc/_html/testpkg/testpkg.lib/Testlib/index.html
  _build/default/_doc/_html/testpkg/testpkg.lib/Testlib/index.html

Check that references to Cmdliner types are remapped to ocaml.org:

  $ grep -o 'href="[^"]*Cmdliner[^"]*"' _build/default/_doc/_html/testpkg/testpkg.lib/Testlib/index.html | sed 's|/[0-9.]*-*[a-z0-9]*/doc|/VERSION/doc|g' | sort -u
  href="../../../cmdliner/cmdliner/Cmdliner/Arg/index.html#type-t"
  href="../../../cmdliner/cmdliner/Cmdliner/Cmd/index.html#val-v"
  href="../../../cmdliner/cmdliner/Cmdliner/Term/index.html#type-t"

Verify there are no unresolved cross-references:

  $ grep -c "xref-unresolved" _build/default/_doc/_html/testpkg/testpkg.lib/Testlib/index.html || true
  0
