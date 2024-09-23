This test generates documentation using odoc for a library:

  $ dune build @doc-new
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/bar/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/bar/page-bar.odoc
  File "_doc_new/odoc/local/foo/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/foo/page-foo.odoc
  File "_doc_new/odoc/local/foo/byte/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/foo/byte/page-byte.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/camlinternalFormatBasics.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/page-stdlib.odoc
  [1]

This test if `.odocl` files are generated
  $ find _build/default/_doc_new/odoc/local -name '*.odocl' | sort -n

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
