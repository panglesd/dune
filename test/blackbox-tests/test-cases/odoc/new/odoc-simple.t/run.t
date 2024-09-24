This test generates documentation using odoc for a library:

  $ dune build @doc-new

This test if `.odocl` files are generated
  $ find _build/default/_doc_new/odoc/local -name '*.odocl' | sort -n
  _build/default/_doc_new/odoc/local/bar/bar.odocl
  _build/default/_doc_new/odoc/local/bar/page-bar.odocl
  _build/default/_doc_new/odoc/local/foo/byte/foo_byte.odocl
  _build/default/_doc_new/odoc/local/foo/byte/page-byte.odocl
  _build/default/_doc_new/odoc/local/foo/foo.odocl
  _build/default/_doc_new/odoc/local/foo/foo2.odocl
  _build/default/_doc_new/odoc/local/foo/page-foo.odocl
  _build/default/_doc_new/odoc/local/page-local.odocl

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
