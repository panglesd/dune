  $ export BUILD_PATH_PREFIX_MAP=odoc=`command -v odoc`

As configured in the `dune` file at the root, this should be an error:

  $ dune build --only-packages=foo_doc @doc
  File "../foo_doc/foo.mld", line 4, characters 0-0:
  Error: End of text is not allowed in '[...]' (code).
  ERROR: Warnings have been generated.
  [1]

Same for documentation in mli files:

  $ dune build --only-packages=foo_lib @doc
  File "domain.mli", line 69, character 4 to line 74, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "array.mli", line 449, character 1 to line 455, character 2:
  Warning: Code blocks should be indented at the opening `{`.
  File "arrayLabels.mli", line 449, character 1 to line 455, character 2:
  Warning: Code blocks should be indented at the opening `{`.
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
  File "gc.mli", line 431, character 3 to line 440, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "buffer.mli", line 35, character 0 to line 37, character 1:
  Error: Alert unsynchronized_access not expected here.
  ERROR: Warnings have been generated.
  File "dynarray.mli", line 47, character 0 to line 49, character 1:
  Error: Alert unsynchronized_access not expected here.
  ERROR: Warnings have been generated.
  File "fun.mli", line 92, characters 3-8:
  Error: 'const' is deprecated, use 'constructor' instead.
  ERROR: Warnings have been generated.
  File "hashtbl.mli", line 47, character 0 to line 49, character 1:
  Error: Alert unsynchronized_access not expected here.
  ERROR: Warnings have been generated.
  File "queue.mli", line 24, character 0 to line 26, character 1:
  Error: Alert unsynchronized_access not expected here.
  ERROR: Warnings have been generated.
  File "scanf.mli", line 86, character 0 to line 88, character 1:
  Error: Alert unsynchronized_access not expected here.
  ERROR: Warnings have been generated.
  File "stack.mli", line 23, character 0 to line 25, character 1:
  Error: Alert unsynchronized_access not expected here.
  ERROR: Warnings have been generated.
  [1]

These packages are in a nested env, the option is disabled, should success with warning printed:

  $ dune build --only-packages=bar_doc,bar_lib @doc
  File "../sub_env/bar_doc/bar.mld", line 4, characters 0-0:
  Error: End of text is not allowed in '[...]' (code).
  ERROR: Warnings have been generated.
  File "buffer.mli", line 35, character 0 to line 37, character 1:
  Error: Alert unsynchronized_access not expected here.
  ERROR: Warnings have been generated.
  File "dynarray.mli", line 47, character 0 to line 49, character 1:
  Error: Alert unsynchronized_access not expected here.
  ERROR: Warnings have been generated.
  File "fun.mli", line 92, characters 3-8:
  Error: 'const' is deprecated, use 'constructor' instead.
  ERROR: Warnings have been generated.
  File "hashtbl.mli", line 47, character 0 to line 49, character 1:
  Error: Alert unsynchronized_access not expected here.
  ERROR: Warnings have been generated.
  File "queue.mli", line 24, character 0 to line 26, character 1:
  Error: Alert unsynchronized_access not expected here.
  ERROR: Warnings have been generated.
  File "scanf.mli", line 86, character 0 to line 88, character 1:
  Error: Alert unsynchronized_access not expected here.
  ERROR: Warnings have been generated.
  File "stack.mli", line 23, character 0 to line 25, character 1:
  Error: Alert unsynchronized_access not expected here.
  ERROR: Warnings have been generated.
  [1]

In release mode, no error:

  $ dune build -p foo_doc,foo_lib @doc
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id foo_doc --enable-missing-root-warning --warnings-tag foo_doc ../foo_doc/foo.mld)
  File "../foo_doc/foo.mld", line 4, characters 0-0:
  Warning: End of text is not allowed in '[...]' (code).
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__Domain.cmti)
  File "domain.mli", line 69, character 4 to line 74, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__Fun.cmti)
  File "fun.mli", line 92, characters 3-8:
  Warning: 'const' is deprecated, use 'constructor' instead.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__Scanf.cmti)
  File "scanf.mli", line 86, character 0 to line 88, character 1:
  Warning: Alert unsynchronized_access not expected here.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__Buffer.cmti)
  File "buffer.mli", line 35, character 0 to line 37, character 1:
  Warning: Alert unsynchronized_access not expected here.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__Array.cmti)
  File "array.mli", line 449, character 1 to line 455, character 2:
  Warning: Code blocks should be indented at the opening `{`.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__ArrayLabels.cmti)
  File "arrayLabels.mli", line 449, character 1 to line 455, character 2:
  Warning: Code blocks should be indented at the opening `{`.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__Bytes.cmti)
  File "bytes.mli", line 368, character 3 to line 373, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytes.mli", line 395, character 3 to line 398, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytes.mli", line 432, character 4 to line 435, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__BytesLabels.cmti)
  File "bytesLabels.mli", line 368, character 3 to line 373, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytesLabels.mli", line 395, character 3 to line 398, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytesLabels.mli", line 432, character 4 to line 435, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__Dynarray.cmti)
  File "dynarray.mli", line 47, character 0 to line 49, character 1:
  Warning: Alert unsynchronized_access not expected here.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__Hashtbl.cmti)
  File "hashtbl.mli", line 47, character 0 to line 49, character 1:
  Warning: Alert unsynchronized_access not expected here.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__Queue.cmti)
  File "queue.mli", line 24, character 0 to line 26, character 1:
  Warning: Alert unsynchronized_access not expected here.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__Stack.cmti)
  File "stack.mli", line 23, character 0 to line 25, character 1:
  Warning: Alert unsynchronized_access not expected here.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__Format.cmti)
  File "format.mli", line 363, character 3 to line 369, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "format.mli", line 372, character 3 to line 375, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "format.mli", line 1575, character 2 to line 1579, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__Ephemeron.cmti)
  File "ephemeron.mli", line 70, character 0 to line 72, character 1:
  Warning: Alert unsynchronized_access not expected here.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__MoreLabels.cmti)
  File "moreLabels.mli", line 64, character 2 to line 66, character 3:
  Warning: Alert unsynchronized_access not expected here.
  (cd _build/default/_doc && odoc compile -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id stdlib/stdlib --enable-missing-root-warning --warnings-tag stdlib /home/tarides/.opam/5.4.0/lib/ocaml/stdlib__Gc.cmti)
  File "gc.mli", line 431, character 3 to line 440, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  (cd _build/default/_doc && odoc compile -I _odoc/foo_lib/foo_lib -I _odoc/stdlib/stdlib --output-dir _odoc --parent-id foo_lib/foo_lib --enable-missing-root-warning --warnings-tag foo_lib ../foo_lib/.foo.objs/byte/foo.cmti)
  File "foo_lib/foo.mli", line 1, characters 7-7:
  Warning: End of text is not allowed in '[...]' (code).
  (cd _build/default/_doc && odoc link -I _odoc/foo_lib/foo_lib -I _odoc/stdlib/stdlib --enable-missing-root-warning --warnings-tags __private_lib__ --warnings-tags foo_doc --warnings-tags foo_lib -o _index/page-index.odocl _index/page-index.odoc)
  File "_index/index.mld", line 4, characters 2-33:
  Warning: Failed to resolve reference /foo_lib/index Path '/foo_lib/index' not found
  File "_index/index.mld", line 3, characters 2-33:
  Warning: Failed to resolve reference /foo_doc/index Path '/foo_doc/index' not found
  (cd _build/default/_doc && odoc link -I _odoc/foo_lib -I _odoc/foo_lib/foo_lib -I _odoc/stdlib/stdlib --enable-missing-root-warning --warnings-tags __private_lib__ --warnings-tags foo_doc --warnings-tags foo_lib -o _odocls/foo_lib/page-index.odocl _odoc/foo_lib/page-index.odoc)
  File "_mlds/foo_lib/index.mld", line 4, characters 0-22:
  Warning: Failed to resolve reference /foo_lib/Foo Path '/foo_lib/Foo' not found
