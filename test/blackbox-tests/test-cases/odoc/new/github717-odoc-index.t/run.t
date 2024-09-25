  $ dune build @doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/html/local/hello_world/hello_world.html:
  - <internal location>
  - <internal location>
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/odoc/local/hello_world/hello_world.mld:
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

  $ grep Test _build/default/_doc_new/html/docs/local/hello_world/index.html > /dev/null || echo Missing
  grep: _build/default/_doc_new/html/docs/local/hello_world/index.html: No such file or directory
  Missing
