Test docs generation with Melange

  $ export DUNE_SANDBOX=none
  $ cat <<EOF > dune-project
  > (lang dune 3.8)
  > (using melange 0.1)
  > (package (name foo))
  > EOF

  $ cat <<EOF > dune
  > (library
  >  (name foo)
  >  (public_name foo)
  >  (modes :standard melange))
  > EOF
  > touch foo.ml bar.ml

Works for "universal" libraries

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

  $ cat _build/default/_doc/_mlds/foo/index.mld
  {0 foo index}
  {1 Library foo}
  The entry point of this library is the module:
  {!module-Foo}.

Works for Melange-only libraries

  $ cat <<EOF > dune
  > (library
  >  (name foo)
  >  (public_name foo)
  >  (modes melange))
  > EOF

  $ dune build @doc
  File "_doc/_odoc/foo/foo/_unknown_", line 1, characters 0-0:
  Error: No rule found for .foo.objs/byte/foo.cmt
  File "_doc/_odoc/foo/foo/_unknown_", line 1, characters 0-0:
  Error: No rule found for .foo.objs/byte/foo__.cmt
  File "_doc/_odoc/foo/foo/_unknown_", line 1, characters 0-0:
  Error: No rule found for .foo.objs/byte/foo__Bar.cmt
  [1]

  $ cat _build/default/_doc/_mlds/foo/index.mld
  {0 foo index}
  {1 Library foo}
  The entry point of this library is the module:
  {!module-Foo}.
