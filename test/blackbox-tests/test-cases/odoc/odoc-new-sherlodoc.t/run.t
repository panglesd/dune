This test generates documentation using odoc for a library:

  $ dune build @doc-new

We index the compiler directory (+ocaml), in which num is optionally present.
To make the test not depend on whether it is installed, we filter the output.

  $ scrub_num () {
  >   grep -v \
  >     -e arith_status.odocl \
  >     -e big_int.odocl \
  >     -e nat.odocl \
  >     -e num.odocl \
  >     -e ratio.odocl
  > }

This test if `.odocl` files are generated
  $ find . -name '*.odocl' | sort -n | scrub_num
  ./_build/default/_doc_new/index/local/bar/page-bar.odocl
  ./_build/default/_doc_new/index/local/foo/byte/page-byte.odocl
  ./_build/default/_doc_new/index/local/foo/page-foo.odocl
  ./_build/default/_doc_new/index/local/page-local.odocl
  ./_build/default/_doc_new/index/page-docs.odocl
  ./_build/default/_doc_new/index/stdlib/page-stdlib.odocl
  ./_build/default/_doc_new/odoc/local/bar/bar.odocl
  ./_build/default/_doc_new/odoc/local/foo/byte/foo_byte.odocl
  ./_build/default/_doc_new/odoc/local/foo/foo.odocl
  ./_build/default/_doc_new/odoc/local/foo/foo2.odocl
  ./_build/default/_doc_new/odoc/stdlib/camlinternalFormat.odocl
  ./_build/default/_doc_new/odoc/stdlib/camlinternalFormatBasics.odocl
  ./_build/default/_doc_new/odoc/stdlib/camlinternalLazy.odocl
  ./_build/default/_doc_new/odoc/stdlib/camlinternalMod.odocl
  ./_build/default/_doc_new/odoc/stdlib/camlinternalOO.odocl
  ./_build/default/_doc_new/odoc/stdlib/std_exit.odocl
  ./_build/default/_doc_new/odoc/stdlib/stdlib.odocl

This test if the sherlodoc js files are generated
  $ find . -name '*.js' | sort -n
  ./_build/default/_doc_new/html/docs/db.js
  ./_build/default/_doc_new/html/docs/odoc.support/highlight.pack.js
  ./_build/default/_doc_new/html/docs/odoc.support/katex.min.js
  ./_build/default/_doc_new/html/docs/odoc.support/odoc_search.js
  ./_build/default/_doc_new/html/docs/sherlodoc.js

  $ cat ./_build/default/_doc_new/html/docs/db.js | scrub_num
  /* Sherlodoc DB for: */
  /*   - ../../odoc/stdlib/camlinternalFormat.odocl */
  /*   - ../../odoc/stdlib/camlinternalFormatBasics.odocl */
  /*   - ../../odoc/stdlib/camlinternalLazy.odocl */
  /*   - ../../odoc/stdlib/camlinternalMod.odocl */
  /*   - ../../odoc/stdlib/camlinternalOO.odocl */
  /*   - ../../odoc/stdlib/std_exit.odocl */
  /*   - ../../odoc/stdlib/stdlib.odocl */
  /*   - --favored ../../index/page-docs.odocl */
  /*   - --favored ../../index/local/page-local.odocl */
  /*   - --favored ../../odoc/local/bar/bar.odocl */
  /*   - --favored ../../index/local/bar/page-bar.odocl */
  /*   - --favored ../../odoc/local/foo/foo2.odocl */
  /*   - --favored ../../odoc/local/foo/foo.odocl */
  /*   - --favored ../../index/local/foo/page-foo.odocl */
  /*   - --favored ../../odoc/local/foo/byte/foo_byte.odocl */
  /*   - --favored ../../index/local/foo/byte/page-byte.odocl */
  $ dune runtest
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
  <!DOCTYPE html>
  <html xmlns="http://www.w3.org/1999/xhtml"><head><title>index (index)</title><meta charset="utf-8"/><link rel="stylesheet" href="odoc.support/odoc.css"/><meta name="generator" content="odoc 3.1.0"/><meta name="viewport" content="width=device-width,initial-scale=1.0"/><script src="odoc.support/highlight.pack.js"></script><script>hljs.initHighlightingOnLoad();</script></head><body class="odoc"><nav class="odoc-nav"></nav><header class="odoc-preamble"><h1 id="ocaml-package-documentation"><a href="#ocaml-package-documentation" class="anchor"></a>OCaml package documentation</h1><ul><li><a href="bar/index.html" title="index">bar</a></li><li><a href="foo/index.html" title="index">foo</a></li></ul></header><div class="odoc-content"></div></body></html>

  $ dune build @foo-mld
  {0 foo index}
  {1 Library foo}
  This library exposes the following toplevel modules:
  {!modules:Foo Foo2}
  {1 Library foo.byte}
  The entry point of this library is the module:
  {!/foo.byte/module-Foo_byte}.

  $ dune build @bar-mld
  {0 bar index}
  {1 Library bar}
  The entry point of this library is the module:
  {!/bar/module-Bar}.
