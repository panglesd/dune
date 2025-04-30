We are going to test the way mld pages are installed. Since odoc 3, pages can be
installed in subdirectories, so that odoc drivers (such as odig or ocaml.org)
are able to recover the hierarchy.

Currently, the only mechanism to install mld pages in subdirectory is to use the
"path" field of the documentation stanza:

  $ cat tutorial/dune
  (documentation
   (path "tutorial/tuto1"))
  $ cat doc/dune
  (documentation)

Here, the mld pages in tutorial/ will be installed in
<page_root>/tutorial/tuto1/ while the ones in doc/ will be installed in
<page_root>/ (where <page_root> is <opam switch root>/doc/<pkgname>/)

Let's verify that:

  $ dune build @install
  $ ls _build/install/default/doc/testing_mld/odoc-pages
  index.mld
  tutorial
  $ ls _build/install/default/doc/testing_mld/odoc-pages/tutorial/tuto1
  file.mld

  $ cat _build/default/testing_mld.install
  lib: [
    "_build/install/default/lib/testing_mld/META"
    "_build/install/default/lib/testing_mld/dune-package"
  ]
  doc: [
    "_build/install/default/doc/testing_mld/odoc-pages/index.mld" {"odoc-pages/index.mld"}
    "_build/install/default/doc/testing_mld/odoc-pages/tutorial/tuto1/file.mld" {"odoc-pages/tutorial/tuto1/file.mld"}
  ]
