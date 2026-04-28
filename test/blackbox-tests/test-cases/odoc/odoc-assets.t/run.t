Test that odoc assets (images, etc.) are properly processed:

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
  File "_doc/_odoc/mylib/_unknown_", line 1, characters 0-0:
  ERROR: Unknown extension, expected one of: cmti, cmt, cmi or mld.
  [1]

Verify the asset .odocl file was compiled:

  $ find _build/default/_doc/_odocls/mylib -name '*.odocl' | sort
  find: '_build/default/_doc/_odocls/mylib': No such file or directory
  [1]

Verify the asset was copied to HTML output:

  $ test -f _build/default/_doc/_html/mylib/logo.png && echo "logo.png exists in HTML output"
  [1]

Verify the index.html references the asset:

  $ test -f _build/default/_doc/_html/mylib/index.html && echo "index.html exists"
  [1]

Test that @doc-full also works with assets:

  $ dune build @doc-full
  Error: Alias "doc-full" specified on the command line is empty.
  It is not defined in . or any of its descendants.
  [1]

Verify asset was copied to HTML full output:

  $ test -f _build/default/_doc/_html_full/mylib/logo.png && echo "logo.png exists in HTML full output"
  [1]

Test that @doc-json also works with assets (assets are copied to JSON output):

  $ dune build @doc-json
  File "_doc/_odoc/mylib/_unknown_", line 1, characters 0-0:
  ERROR: Unknown extension, expected one of: cmti, cmt, cmi or mld.
  [1]

Verify JSON files are generated:

  $ find _build/default/_doc/_json/mylib -name '*.json' | sort
  find: '_build/default/_doc/_json/mylib': No such file or directory
  [1]

Verify the asset was copied to JSON output:

  $ test -f _build/default/_doc/_json/mylib/logo.png && echo "logo.png exists in JSON output"
  [1]

Test that @doc-json-full also works with assets:

  $ dune build @doc-json-full
  Error: Alias "doc-json-full" specified on the command line is empty.
  It is not defined in . or any of its descendants.
  [1]

Verify asset was copied to JSON full output:

  $ test -f _build/default/_doc/_json_full/mylib/logo.png && echo "logo.png exists in JSON full output"
  [1]
