Test that package mld files can reference modules from other packages.
Package A's index.mld contains a reference to {!Libb} from package B.
With documentation dependencies declared in dune-project, cross-package references resolve correctly.

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
  File "_index/index.mld", line 4, characters 2-27:
  Warning: Failed to resolve reference /pkgb/index Path '/pkgb/index' not found
  File "_index/index.mld", line 3, characters 2-27:
  Warning: Failed to resolve reference /pkga/index Path '/pkga/index' not found

Verify documentation was generated for both packages:

  $ find _build/default/_doc/_odocls/{pkga,pkgb} -name '*.odocl' | sort -n
  _build/default/_doc/_odocls/pkga/page-index.odocl
  _build/default/_doc/_odocls/pkga/pkga.lib/liba.odocl
  _build/default/_doc/_odocls/pkga/pkga.lib/page-index.odocl
  _build/default/_doc/_odocls/pkgb/page-index.odocl
  _build/default/_doc/_odocls/pkgb/pkgb.lib/libb.odocl
  _build/default/_doc/_odocls/pkgb/pkgb.lib/page-index.odocl

Check that HTML was generated for both package indexes:

  $ ls _build/default/_doc/_html/pkga/index.html
  _build/default/_doc/_html/pkga/index.html

  $ ls _build/default/_doc/_html/pkgb/index.html
  _build/default/_doc/_html/pkgb/index.html

Both libraries' HTML should be generated with cross-package references resolved:

  $ ls _build/default/_doc/_html/pkga/pkga.lib/Liba/index.html
  _build/default/_doc/_html/pkga/pkga.lib/Liba/index.html

  $ ls _build/default/_doc/_html/pkgb/pkgb.lib/Libb/index.html
  _build/default/_doc/_html/pkgb/pkgb.lib/Libb/index.html

Verify that all cross-package references resolved correctly (no unresolved xrefs):

  $ grep -r "xref-unresolved" _build/default/_doc/_html/pkga/ _build/default/_doc/_html/pkgb/
  [1]
