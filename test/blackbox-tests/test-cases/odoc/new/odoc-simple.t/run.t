This test generates documentation using odoc for a library:

  $ dune build @doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/html/local/bar/bar.html:
  - <internal location>
  - <internal location>
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/html/local/foo/foo.html:
  - <internal location>
  - <internal location>
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/odoc/local/bar/bar.mld:
  - <internal location>
  - <internal location>
  -> required by _build/default/_doc_new/html/db.js
  -> required by
     _build/default/_doc_new/html/stdlib/CamlinternalFormat/index.html
  -> required by alias _doc_new/html/stdlib/doc-new
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/odoc/local/foo/foo.mld:
  - <internal location>
  - <internal location>
  -> required by _build/default/_doc_new/html/db.js
  -> required by
     _build/default/_doc_new/html/stdlib/CamlinternalFormat/index.html
  -> required by alias _doc_new/html/stdlib/doc-new
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: No rule found for _doc_new/html/docs.html
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  [1]

This test if `.odocl` files are generated
  $ find _build/default/_doc_new/odoc/local -name '*.odocl' | sort -n
  find: '_build/default/_doc_new/odoc/local': No such file or directory

  $ ls _build/default/_doc_new/html/docs/local/
  ls: cannot access '_build/default/_doc_new/html/docs/local/': No such file or directory
  [2]

  $ dune build @foo-mld
  Error: No rule found for _doc_new/index/local/foo/foo.mld
  -> required by alias foo-mld in dune:19
  [1]

  $ dune build @bar-mld
  Error: No rule found for _doc_new/index/local/bar/bar.mld
  -> required by alias bar-mld in dune:24
  [1]
