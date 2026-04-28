Source rendering test - verify impl artifacts are compiled, linked, and generate source HTML:

  $ dune build @doc 2>&1 | head -20
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
  [141]

Check that impl .odoc files are generated:

  $ find _build/default/_doc/_odoc -name 'impl-*' | sort

Check that impl .odocl files are generated:

  $ find _build/default/_doc/_odocls -name 'impl-*' | sort
  find: '_build/default/_doc/_odocls': No such file or directory
  [1]

Check that source HTML is generated (look for any source-related files):

  $ find _build/default/_doc/_html -name '*.html' | sort

Check that source links are present in the module documentation page:

  $ grep -o 'class="source_link">[^<]*' _build/default/_doc/_html/mypkg/mypkg.mylib/Mylib/index.html | sort -u
  grep: _build/default/_doc/_html/mypkg/mypkg.mylib/Mylib/index.html: No such file or directory
  [2]

Check that source links point to the source file:

  $ grep -o 'href="[^"]*mylib.ml.html[^"]*" class="source_link"' _build/default/_doc/_html/mypkg/mypkg.mylib/Mylib/index.html | sort -u
  grep: _build/default/_doc/_html/mypkg/mypkg.mylib/Mylib/index.html: No such file or directory
  [2]
