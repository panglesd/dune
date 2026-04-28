Test that markdown generation includes all modules following naming conventions.

  $ cat > dune-project << EOF
  > (lang dune 3.0)
  > (package (name mylib))
  > EOF

  $ cat > dune << EOF
  > (library
  >  (public_name mylib))
  > EOF

  $ dune build @doc-markdown
  File "_index/index.mld", line 3, characters 2-29:
  Warning: Failed to resolve reference /mylib/index Path '/mylib/index' not found
  File "domain.mli", line 69, character 4 to line 74, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "fun.mli", line 92, characters 3-8:
  Warning: 'const' is deprecated, use 'constructor' instead.
  File "scanf.mli", line 86, character 0 to line 88, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "array.mli", line 449, character 1 to line 455, character 2:
  Warning: Code blocks should be indented at the opening `{`.
  File "arrayLabels.mli", line 449, character 1 to line 455, character 2:
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
  File "format.mli", line 363, character 3 to line 369, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "format.mli", line 372, character 3 to line 375, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "format.mli", line 1575, character 2 to line 1579, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "ephemeron.mli", line 70, character 0 to line 72, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "moreLabels.mli", line 64, character 2 to line 66, character 3:
  Warning: Alert unsynchronized_access not expected here.
  File "gc.mli", line 431, character 3 to line 440, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "_mlds/mylib/index.mld", line 4, characters 0-22:
  Warning: Failed to resolve reference /mylib/Mylib Path '/mylib/Mylib' not found

  $ find _build/default/_doc/_markdown -name "*.md" | sort
  _build/default/_doc/_markdown/index.md
  _build/default/_doc/_markdown/mylib/index.md
  _build/default/_doc/_markdown/mylib/mylib/Mylib-Main.md
  _build/default/_doc/_markdown/mylib/mylib/Mylib-Main_nested.md
  _build/default/_doc/_markdown/mylib/mylib/Mylib-Main_nested_deep.md
  _build/default/_doc/_markdown/mylib/mylib/Mylib-Main_sub.md
  _build/default/_doc/_markdown/mylib/mylib/Mylib.md
  _build/default/_doc/_markdown/mylib/mylib/index.md

  $ cat _build/default/_doc/_markdown/mylib/Mylib.md
  cat: _build/default/_doc/_markdown/mylib/Mylib.md: No such file or directory
  [1]
