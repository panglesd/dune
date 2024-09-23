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
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/l/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/l/page-l.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/camlinternalFormatBasics.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/page-stdlib.odoc
  [1]
  $ detect _build/default/_doc_new/html/docs/local/l/L/index.html
  grep: _build/default/_doc_new/html/docs/local/l/L/index.html: No such file or directory
  grep: _build/default/_doc_new/html/docs/local/l/L/index.html: No such file or directory
  it is unknown

  $ ODOC_SYNTAX=re dune build @doc-new
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/l/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/l/page-l.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/camlinternalFormatBasics.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/page-stdlib.odoc
  [1]
  $ detect _build/default/_doc_new/html/docs/local/l/L/index.html
  grep: _build/default/_doc_new/html/docs/local/l/L/index.html: No such file or directory
  grep: _build/default/_doc_new/html/docs/local/l/L/index.html: No such file or directory
  it is unknown
