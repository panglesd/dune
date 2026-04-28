Test that packages discovered through the library closure get -P flags
during odoc link, even when they are not listed as :with-doc dependencies.

Setup: pkga depends on pkgb (:with-doc) and liba depends on pkgc.lib
and odoc-parser. pkgc is a local package NOT listed as :with-doc.
odoc-parser is an installed package NOT listed as :with-doc.
Both should be discovered through the library closure.

Build documentation:

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
  File "src/astring.mli", line 229, characters 39-62:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 484, characters 41-64:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 993, characters 45-68:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 1000, characters 45-68:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 1007, characters 44-67:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 1014, characters 40-63:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 1051, characters 53-76:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 1058, characters 53-76:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 1065, characters 48-71:
  Warning: '@raise' should begin on its own line.

Verify documentation was generated for all three local packages
(pkgc is included even though it's not a :with-doc dep, because
liba depends on pkgc.lib):

  $ find _build/default/_doc/_odocls -name '*.odocl' | sort
  _build/default/_doc/_odocls/pkga/page-index.odocl
  _build/default/_doc/_odocls/pkga/pkga.lib/liba.odocl
  _build/default/_doc/_odocls/pkga/pkga.lib/page-index.odocl
  _build/default/_doc/_odocls/pkgb/page-index.odocl
  _build/default/_doc/_odocls/pkgb/pkgb.lib/libb.odocl
  _build/default/_doc/_odocls/pkgb/pkgb.lib/page-index.odocl
  _build/default/_doc/_odocls/pkgc/page-index.odocl
  _build/default/_doc/_odocls/pkgc/pkgc.lib/libc.odocl
  _build/default/_doc/_odocls/pkgc/pkgc.lib/page-index.odocl

Verify that Libc references in liba's HTML point to local paths:

  $ grep -o 'href="[^"]*Libc[^"]*"' _build/default/_doc/_html/pkga/pkga.lib/Liba/index.html | sort -u
  href="../../../pkgc/pkgc.lib/Libc/index.html#type-c_type"
  href="../../../pkgc/pkgc.lib/Libc/index.html#val-c_function"

Verify that Odoc_parser references are remapped to ocaml.org (installed pkg):

  $ grep -o 'href="[^"]*Odoc_parser[^"]*"' _build/default/_doc/_html/pkga/pkga.lib/Liba/index.html | sed 's|/[0-9.]*-*[a-z0-9]*/doc|/VERSION/doc|g' | sort -u
  href="../../../odoc-parser/odoc-parser/Odoc_parser/index.html#type-t"

Inspect the link rule for liba to verify that -P flags include packages from
the library closure. In particular, odoc-parser and pkgc must appear even
though they are not :with-doc deps - they are discovered as transitive library
dependencies:

  $ dune rules _build/default/_doc/_odocls/pkga/pkga.lib/liba.odocl 2>&1 | grep -E '^\s+\-P$' -A1 | grep -v '^\s*-P$' | grep -v '^--$' | sed 's|^ *||' | sed 's|:.*||' | sort -u
  astring
  camlp-streams
  odoc-parser
  pkga
  pkgb
  pkgc
