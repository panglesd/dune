Test that references to installed libraries like Lwt work correctly.
This verifies that cross-library references in documentation comments
are resolved correctly when linking.

Build documentation:

  $ dune build @doc
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
  File "src/core/lwt_sequence.mli", line 21, character 0 to line 23, character 41:
  Warning: Alert deprecated not expected here.
  File "src/core/lwt_pool.mli", line 23, character 4 to line 39, character 2:
  Warning: Code blocks should be indented at the opening `{`.
  File "_index/index.mld", line 3, characters 2-29:
  Warning: Failed to resolve reference /mylib/index Path '/mylib/index' not found

Check that documentation was generated without broken reference warnings:

  $ find _build/default/_doc/_odocls/mylib -name '*.odocl' | sort -n
  _build/default/_doc/_odocls/mylib/mylib/mylib.odocl
  _build/default/_doc/_odocls/mylib/mylib/page-index.odocl
  _build/default/_doc/_odocls/mylib/page-index.odocl

Check that HTML was generated for our library:

  $ find _build/default/_doc/_html/mylib -name '*.html' | sort -n
  _build/default/_doc/_html/mylib/index.html
  _build/default/_doc/_html/mylib/mylib/Mylib/index.html
  _build/default/_doc/_html/mylib/mylib/index.html

Verify that Lwt documentation was also built (needed for cross-references):

  $ ls _build/default/_doc/_odoc/lwt/lwt/Lwt.odoc
  ls: cannot access '_build/default/_doc/_odoc/lwt/lwt/Lwt.odoc': No such file or directory
  [2]

Check that the generated HTML contains links to Lwt types:

  $ grep -o "href=\"[^\"]*Lwt[^\"]*\"" _build/default/_doc/_html/mylib/mylib/Mylib/index.html | head -3
  href="../../../lwt/lwt/Lwt/index.html#type-t"
  href="../../../lwt/lwt/Lwt/index.html#type-t"
  href="../../../lwt/lwt/Lwt/index.html#type-t"
