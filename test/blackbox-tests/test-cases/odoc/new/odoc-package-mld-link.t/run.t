Make sure that links between mld files are resolved even when there is
no library associated with the project

This test case is based on code provided by @vphantom, ocaml/dune#2007

  $ dune build @doc-new
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/odoc_page_link_bug/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/odoc_page_link_bug/page-odoc_page_link_bug.odoc
  File "_doc_new/odoc/local/odoc_page_link_bug/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/odoc_page_link_bug/page-otherpage.odoc
  [1]

  $ grep -r xref-unresolved _build/default/_doc_new/html/docs/local/odoc_page_link_bug/index.html
  grep: _build/default/_doc_new/html/docs/local/odoc_page_link_bug/index.html: No such file or directory
  [2]
