This test generates documentation using odoc for a library:
  $ ls
  bar.ml
  bar.opam
  dune
  dune-project
  foo.ml
  foo.opam
  foo2.ml
  foo3.ml
  foo_byte.ml

  $ dune build @doc-very-new
  Error: Multiple rules generated for
  _build/default/_doc_very_new/html/local/bar/bar.html:
  - <internal location>
  - <internal location>
  -> required by alias _doc_very_new/html/doc-very-new
  -> required by alias doc-very-new
  Error: Multiple rules generated for
  _build/default/_doc_very_new/html/local/foo/foo.html:
  - <internal location>
  - <internal location>
  -> required by alias _doc_very_new/html/doc-very-new
  -> required by alias doc-very-new
  Error: Multiple rules generated for
  _build/default/_doc_very_new/odoc/local/bar/bar.mld:
  - <internal location>
  - <internal location>
  -> required by _build/default/_doc_very_new/html/db.js
  -> required by
     _build/default/_doc_very_new/html/stdlib/CamlinternalFormat/index.html
  -> required by alias _doc_very_new/html/stdlib/doc-very-new
  -> required by alias _doc_very_new/html/doc-very-new
  -> required by alias doc-very-new
  Error: Multiple rules generated for
  _build/default/_doc_very_new/odoc/local/foo/foo.mld:
  - <internal location>
  - <internal location>
  -> required by _build/default/_doc_very_new/html/db.js
  -> required by
     _build/default/_doc_very_new/html/stdlib/CamlinternalFormat/index.html
  -> required by alias _doc_very_new/html/stdlib/doc-very-new
  -> required by alias _doc_very_new/html/doc-very-new
  -> required by alias doc-very-new
  Error: No rule found for _doc_very_new/html/docs.html
  -> required by alias _doc_very_new/html/doc-very-new
  -> required by alias doc-very-new
  [1]

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
  ./_build/default/_doc_very_new/odoc/stdlib/camlinternalFormat.odocl
  ./_build/default/_doc_very_new/odoc/stdlib/camlinternalFormatBasics.odocl
  ./_build/default/_doc_very_new/odoc/stdlib/camlinternalLazy.odocl
  ./_build/default/_doc_very_new/odoc/stdlib/camlinternalMod.odocl
  ./_build/default/_doc_very_new/odoc/stdlib/camlinternalOO.odocl
  ./_build/default/_doc_very_new/odoc/stdlib/page-stdlib.odocl
  ./_build/default/_doc_very_new/odoc/stdlib/std_exit.odocl
  ./_build/default/_doc_very_new/odoc/stdlib/stdlib.odocl

This test if the sherlodoc js files are generated
  $ find . -name '*.js' | sort -n
  ./_build/default/_doc_new/html/docs/db.js
  ./_build/default/_doc_new/html/docs/odoc.support/highlight.pack.js
  ./_build/default/_doc_new/html/docs/odoc.support/katex.min.js
  ./_build/default/_doc_new/html/docs/odoc.support/odoc_search.js
  ./_build/default/_doc_new/html/docs/sherlodoc.js
  ./_build/default/_doc_very_new/html/docs/odoc.support/highlight.pack.js
  ./_build/default/_doc_very_new/html/docs/odoc.support/katex.min.js
  ./_build/default/_doc_very_new/html/docs/odoc.support/odoc_search.js
  ./_build/default/_doc_very_new/html/sherlodoc.js

  $ cat ./_build/default/_doc_new/html/db.js | scrub_num
  cat: ./_build/default/_doc_new/html/db.js: No such file or directory
  [1]
  $ dune runtest
  <!DOCTYPE html>
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>index</title>
      <link rel="stylesheet" href="./odoc.support/odoc.css"/>
      <meta charset="utf-8"/>
      <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
    </head>
    <body>
      <main class="content">
        <div class="by-name">
        <h2>OCaml package documentation</h2>
        <ol>
        <li><a href="bar/index.html">bar</a></li>
        <li><a href="foo/index.html">foo</a></li>
        </ol>
        </div>
      </main>
    </body>
  </html>

  $ dune build @foo-mld
  {0 foo index}
  {1 Library foo}
  This library exposes the following toplevel modules:
  {!modules:Foo Foo2}
  {1 Library foo.byte}
  The entry point of this library is the module:
  {!module-Foo_byte}.

  $ dune build @bar-mld
  {0 bar index}
  {1 Library bar}
  The entry point of this library is the module:
  {!module-Bar}.
