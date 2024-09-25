The rules that call odoc know that it is going to read the ODOC_SYNTAX
variable, and can rebuild as needed.

  $ cat > dune-project << EOF
  > (lang dune 1.1)
  > (package (name l))
  > EOF

  $ cat > dune << EOF
  > (library
  >  (public_name l))
  > EOF

  $ cat > l.ml << EOF
  > module type X = sig end
  > EOF

  $ detect () {
  > if grep -q '>sig<' $1 ; then
  >   echo it is ocaml
  > elif grep -q '{ ... }' $1 ; then
  >   echo it is reason
  > else
  >   echo it is unknown
  > fi
  > }

  $ dune build @doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/html/local/l/l.html:
  - <internal location>
  - <internal location>
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/odoc/local/l/l.mld:
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
  $ detect _build/default/_doc_new/html/docs/local/l/L/index.html
  grep: _build/default/_doc_new/html/docs/local/l/L/index.html: No such file or directory
  grep: _build/default/_doc_new/html/docs/local/l/L/index.html: No such file or directory
  it is unknown

  $ ODOC_SYNTAX=re dune build @doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/html/local/l/l.html:
  - <internal location>
  - <internal location>
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/odoc/local/l/l.mld:
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
  $ detect _build/default/_doc_new/html/docs/local/l/L/index.html
  grep: _build/default/_doc_new/html/docs/local/l/L/index.html: No such file or directory
  grep: _build/default/_doc_new/html/docs/local/l/L/index.html: No such file or directory
  it is unknown
