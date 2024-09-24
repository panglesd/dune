  $ dune build @doc-new

  $ grep Test _build/default/_doc_new/html/docs/local/hello_world/index.html > /dev/null || echo Missing
  grep: _build/default/_doc_new/html/docs/local/hello_world/index.html: No such file or directory
  Missing
