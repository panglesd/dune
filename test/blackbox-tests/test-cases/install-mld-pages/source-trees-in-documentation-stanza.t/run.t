We are going to test the way mld pages are installed. Since odoc 3, pages can be
installed in subdirectories, so that odoc drivers (such as odig or ocaml.org)
are able to recover the hierarchy.

One mechanism to install mld pages in subdirectory is to use the "path" field of
the documentation stanza:

  $ cat dune
  (documentation
   (source_trees doc/))
  
  (documentation
   (source_trees (doc2/ as .)))

Here, the mld pages in tutorial/ will be installed in
<page_root>/tutorial/tuto1/ while the ones in doc/ will be installed in
<page_root>/ (where <page_root> is <opam switch root>/doc/<pkgname>/)

Let's verify that:

  $ dune build @install
  $ ls -F _build/install/default/doc/testing_mld/odoc-pages
  doc/
  examples/
  index.mld@
  tutorial/
  $ ls _build/install/default/doc/testing_mld/odoc-pages/tutorial/
  tuto1.mld

  $ cat _build/default/testing_mld.install
  lib: [
    "_build/install/default/lib/testing_mld/META"
    "_build/install/default/lib/testing_mld/dune-package"
  ]
  doc: [
    "_build/install/default/doc/testing_mld/odoc-pages/doc/examples/example1/index.mld" {"odoc-pages/doc/examples/example1/index.mld"}
    "_build/install/default/doc/testing_mld/odoc-pages/doc/examples/example2/index.mld" {"odoc-pages/doc/examples/example2/index.mld"}
    "_build/install/default/doc/testing_mld/odoc-pages/doc/examples/index.mld" {"odoc-pages/doc/examples/index.mld"}
    "_build/install/default/doc/testing_mld/odoc-pages/doc/examples/summary.mld" {"odoc-pages/doc/examples/summary.mld"}
    "_build/install/default/doc/testing_mld/odoc-pages/doc/index.mld" {"odoc-pages/doc/index.mld"}
    "_build/install/default/doc/testing_mld/odoc-pages/doc/tutorial/tuto1.mld" {"odoc-pages/doc/tutorial/tuto1.mld"}
    "_build/install/default/doc/testing_mld/odoc-pages/examples/example1/index.mld" {"odoc-pages/examples/example1/index.mld"}
    "_build/install/default/doc/testing_mld/odoc-pages/examples/example2/index.mld" {"odoc-pages/examples/example2/index.mld"}
    "_build/install/default/doc/testing_mld/odoc-pages/examples/index.mld" {"odoc-pages/examples/index.mld"}
    "_build/install/default/doc/testing_mld/odoc-pages/examples/summary.mld" {"odoc-pages/examples/summary.mld"}
    "_build/install/default/doc/testing_mld/odoc-pages/index.mld" {"odoc-pages/index.mld"}
    "_build/install/default/doc/testing_mld/odoc-pages/tutorial/tuto1.mld" {"odoc-pages/tutorial/tuto1.mld"}
  ]
