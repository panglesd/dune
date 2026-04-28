Test sidebar generation for documentation

Setup a project with two packages:

  $ cat > dune-project <<EOF
  > (lang dune 3.17)
  > (package (name foo))
  > (package (name bar))
  > EOF

  $ cat > foo.opam <<EOF
  > opam-version: "2.0"
  > EOF

  $ cat > bar.opam <<EOF
  > opam-version: "2.0"
  > EOF

  $ mkdir foo bar

  $ cat > foo/dune <<EOF
  > (library
  >  (name foo)
  >  (public_name foo))
  > EOF

  $ cat > foo/foo.ml <<EOF
  > (** Foo library *)
  > let greet name = "Hello, " ^ name
  > EOF

  $ cat > bar/dune <<EOF
  > (library
  >  (name bar)
  >  (public_name bar)
  >  (libraries foo))
  > EOF

  $ cat > bar/bar.ml <<EOF
  > (** Bar library - uses Foo *)
  > let say_hello () = Foo.greet "world"
  > EOF

Test 1: Default per-package sidebar with @doc
=============================================

  $ dune build @doc

Check that per-package sidebar files are generated:

  $ find _build/default/_doc/_sidebar -name "*.odoc-sidebar" | sort
  find: '_build/default/_doc/_sidebar': No such file or directory
  [1]

Check that HTML is generated for both packages:

  $ ls _build/default/_doc/_html/foo/foo/Foo/index.html
  _build/default/_doc/_html/foo/foo/Foo/index.html

  $ ls _build/default/_doc/_html/bar/bar/Bar/index.html
  _build/default/_doc/_html/bar/bar/Bar/index.html

Test 2: Global sidebar configuration
====================================

  $ dune clean

Create workspace with global sidebar:

  $ cat > dune-workspace <<EOF
  > (lang dune 3.17)
  > (env
  >  (dev
  >   (odoc
  >    (sidebar global))))
  > EOF

  $ dune build @doc
  File "dune-workspace", line 5, characters 4-11:
  5 |    (sidebar global))))
          ^^^^^^^
  Error: Unknown field "sidebar"
  [1]

Check that global sidebar is generated:

  $ ls _build/default/_doc/_sidebar/sidebar.odoc-sidebar
  ls: cannot access '_build/default/_doc/_sidebar/sidebar.odoc-sidebar': No such file or directory
  [2]

Check that sidebar.json is built by @doc when sidebar is global:

  $ ls _build/default/_doc/_html/sidebar.json
  ls: cannot access '_build/default/_doc/_html/sidebar.json': No such file or directory
  [2]
