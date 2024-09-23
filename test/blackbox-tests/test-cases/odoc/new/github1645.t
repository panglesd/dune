We create two libraries `l.one` and `l.two` with a conflicting module.
They build fine, are not co-linkable, but documentation should be able to be
built. See #1645.

  $ cat > dune-project << EOF
  > (lang dune 1.0)
  > (package (name l))
  > EOF

  $ mkdir one
  $ cat > one/dune << EOF
  > (library
  >  (name l_one)
  >  (public_name l.one)
  >  (wrapped false))
  > EOF
  $ touch one/module.ml

  $ mkdir two
  $ cat > two/dune << EOF
  > (library
  >  (name l_two)
  >  (public_name l.two)
  >  (wrapped false))
  > EOF
  $ touch two/module.ml

  $ dune build @install
  $ dune build @doc-new
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/l/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/l/page-l.odoc
  File "_doc_new/odoc/local/l/one/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/l/one/page-one.odoc
  File "_doc_new/odoc/local/l/two/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/l/two/page-two.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/camlinternalFormatBasics.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/page-stdlib.odoc
  [1]
