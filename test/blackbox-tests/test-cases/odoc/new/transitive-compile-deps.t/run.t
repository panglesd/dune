This test checks that compilation dependencies are correct

  $ dune build @doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/html/local/odoctest3/odoctest3.html:
  - <internal location>
  - <internal location>
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/odoc/local/odoctest3/odoctest3.mld:
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

There should be an expansion of S:

  $ ls _build/default/_doc_new/html/docs/local/odoctest3/Odoctest3/C/
  ls: cannot access '_build/default/_doc_new/html/docs/local/odoctest3/Odoctest3/C/': No such file or directory
  [2]
