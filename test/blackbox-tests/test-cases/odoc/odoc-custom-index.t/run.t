Test that a custom workspace-level index.mld can be specified in dune-project.

  $ cat > dune-project << EOF
  > (lang dune 3.21)
  > (name mylib)
  > (doc_index docs/index.mld)
  > (package (name mylib))
  > EOF

  $ mkdir -p docs
  $ cat > docs/index.mld << EOF
  > {0 My Custom Documentation Index}
  > 
  > This is a custom index page for the workspace.
  > 
  > {1 Packages}
  > 
  > - {{!mylib}mylib} - My library
  > EOF

  $ cat > dune << EOF
  > (library
  >  (name mylib)
  >  (public_name mylib))
  > EOF

  $ cat > mylib.ml << EOF
  > (** My library module *)
  > let hello () = "Hello"
  > EOF

Build the documentation:

  $ dune build @doc 2>&1
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

Verify the custom index content is used (check the mld file in the build):

  $ cat _build/default/_doc/_index/index.mld
  {0 My Custom Documentation Index}
  
  This is a custom index page for the workspace.
  
  {1 Packages}
  
  - {{!mylib}mylib} - My library







Verify the HTML is generated:

  $ test -f _build/default/_doc/_html/index.html && echo "index.html exists"
  index.html exists
