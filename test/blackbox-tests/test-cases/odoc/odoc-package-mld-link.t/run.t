Make sure that links between mld files are resolved even when there is
no library associated with the project

This test case is based on code provided by @vphantom, ocaml/dune#2007

  $ dune build _doc/_html/odoc_page_link_bug/index.html
  File "_doc/_odocls/odoc_page_link_bug/_unknown_", line 1, characters 0-0:
  Error: No rule found for alias _doc/_odoc/odoc_page_link_bug/.odoc-all
  [1]

  $ grep -r xref-unresolved _build/default/_doc/_html/odoc_page_link_bug/index.html
  grep: _build/default/_doc/_html/odoc_page_link_bug/index.html: No such file or directory
  [2]

