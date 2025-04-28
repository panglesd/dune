Test the error cases for dune's Ordered Set Language (OSL) DSL.

  $ cat > dune-project <<EOF
  > (lang dune 3.14)
  > (package
  >  (name rien)
  >  (doc_depends
  >    (packages blibli blublu)))
  > (generate_opam_files true)
  > EOF

  $ cat > foo.mld <<EOF
  > let () = print_endline "foo"
  > EOF

  $ touch bli.jpg
  $ mkdir prout
  $ touch prout/foo2.txt


Make a dune file and build the project, using the "flags" field to exercise OSL.
  $ cat > dune <<EOF
  > (include_subdirs as_documentation)
  > ; (library (name rien))
  > (documentation
  >  (mld_files foo)
  >  (files (glob_files_rec prout/*))
  >  (path test)
  >  )
  > EOF
  $ dune build -p rien @install @all

  $ cat rien.install
  lib: [
    "_build/install/default/lib/rien/META"
    "_build/install/default/lib/rien/dune-package"
    "_build/install/default/lib/rien/opam"
  ]
  doc: [
    "_build/install/default/doc/rien/odoc-config.sexp"
    "_build/install/default/doc/rien/odoc-pages/test/foo.mld" {"odoc-pages/test/foo.mld"}
    "_build/install/default/doc/rien/odoc-pages/test/prout/foo2.txt" {"odoc-pages/test/prout/foo2.txt"}
  ]

  $ ls -R _build/
  _build/:
  default
  install
  log
  
  _build/default:
  META.rien
  foo.mld
  prout
  rien.dune-package
  rien.install
  rien.odoc-config.sexp
  rien.opam
  
  _build/default/prout:
  foo2.txt
  
  _build/install:
  default
  
  _build/install/default:
  doc
  lib
  
  _build/install/default/doc:
  rien
  
  _build/install/default/doc/rien:
  odoc-config.sexp
  odoc-pages
  
  _build/install/default/doc/rien/odoc-pages:
  test
  
  _build/install/default/doc/rien/odoc-pages/test:
  foo.mld
  prout
  
  _build/install/default/doc/rien/odoc-pages/test/prout:
  foo2.txt
  
  _build/install/default/lib:
  rien
  
  _build/install/default/lib/rien:
  META
  dune-package
  opam

  $ cat _build/install/default/doc/rien/odoc-config.sexp
  (libraries )
  (packages blibli blublu)


  $ dune build @doc
  Error: Package rien has two mld's with the same basename
  _build/default/prout/foo2.txt, _build/default/prout/foo2.txt
  -> required by alias doc
  [1]
