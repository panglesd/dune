Source rendering for virtual library implementations.
The virtual library provides the documentation (.cmti) while the implementation
library provides the source code (.cmt). Source links in the vlib's docs should
point to the implementation's source.

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

Check that impl .odoc files are generated for the implementation library:

  $ find _build/default/_doc/_odoc -name 'impl-*' | sort

Check that impl .odocl files are generated:

  $ find _build/default/_doc/_odocls -name 'impl-*' | sort
  find: '_build/default/_doc/_odocls': No such file or directory
  [1]

Check that source HTML is generated:

  $ find _build/default/_doc/_html -name '*.html' | sort

Check that mymod.ml.html source file exists:

  $ test -f _build/default/_doc/_html/mypkg/mypkg.mylib/mymod.ml.html && echo "exists" || echo "missing"
  missing

Check that source links are present in the virtual library's module documentation:

  $ grep -o 'class="source_link">[^<]*' _build/default/_doc/_html/mypkg/mypkg.mylib/Mylib/Mymod/index.html | sort -u
  grep: _build/default/_doc/_html/mypkg/mypkg.mylib/Mylib/Mymod/index.html: No such file or directory
  [2]

Check that source links point to the implementation's source file:

  $ grep -o 'href="[^"]*mymod.ml.html[^"]*" class="source_link"' _build/default/_doc/_html/mypkg/mypkg.mylib/Mylib/Mymod/index.html | sort -u
  grep: _build/default/_doc/_html/mypkg/mypkg.mylib/Mylib/Mymod/index.html: No such file or directory
  [2]
