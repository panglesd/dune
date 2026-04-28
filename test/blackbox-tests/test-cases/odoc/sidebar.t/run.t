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
  File "domain.mli", line 69, character 4 to line 74, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "scanf.mli", line 86, character 0 to line 88, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "array.mli", line 433, character 1 to line 439, character 2:
  Warning: Code blocks should be indented at the opening `{`.
  File "arrayLabels.mli", line 433, character 1 to line 439, character 2:
  Warning: Code blocks should be indented at the opening `{`.
  File "buffer.mli", line 35, character 0 to line 37, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "bytes.mli", line 368, character 3 to line 373, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytes.mli", line 395, character 3 to line 398, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytes.mli", line 432, character 4 to line 435, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytesLabels.mli", line 368, character 3 to line 373, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytesLabels.mli", line 395, character 3 to line 398, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytesLabels.mli", line 432, character 4 to line 435, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "dynarray.mli", line 47, character 0 to line 49, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "hashtbl.mli", line 47, character 0 to line 49, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "queue.mli", line 24, character 0 to line 26, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "stack.mli", line 23, character 0 to line 25, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "format.mli", line 362, character 3 to line 368, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "format.mli", line 371, character 3 to line 374, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "format.mli", line 1538, character 2 to line 1542, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "ephemeron.mli", line 70, character 0 to line 72, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "moreLabels.mli", line 64, character 2 to line 66, character 3:
  Warning: Alert unsynchronized_access not expected here.
  File "gc.mli", line 429, character 3 to line 438, character 5:
  Warning: Code blocks should be indented at the opening `{`.

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
