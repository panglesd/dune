  $ dune build @doc-new
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/hello_world/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/hello_world/page-hello_world.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/camlinternalFormatBasics.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/page-stdlib.odoc
  [1]

  $ grep Test _build/default/_doc_new/html/docs/local/hello_world/index.html > /dev/null || echo Missing
  grep: _build/default/_doc_new/html/docs/local/hello_world/index.html: No such file or directory
  Missing
