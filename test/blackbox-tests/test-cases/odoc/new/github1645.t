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
