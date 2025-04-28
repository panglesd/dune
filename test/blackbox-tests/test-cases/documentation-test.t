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
  Filename: _build/default/bli.jpg
  Filename: _build/default/dune
  Filename: _build/default/dune-project
  Filename: _build/default/foo.mld
  Filename: _build/default/prout/foo2.txt
  Error: The package rien does not have any user defined stanzas attached to
  it. If this is intentional, add (allow_empty) to the package definition in
  the dune-project file
  -> required by _build/default/rien.install
  -> required by alias install
  [1]

  $ cat rien.install
  cat: rien.install: No such file or directory
  [1]

  $ ls -R _build/
  _build/:
  default
  install
  log
  
  _build/default:
  META.rien
  prout
  rien.dune-package
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
  Filename: _build/default/bli.jpg
  Filename: _build/default/dune
  Filename: _build/default/dune-project
  Filename: _build/default/foo.mld
  Filename: _build/default/rien.opam
  Filename: _build/default/prout/foo2.txt
