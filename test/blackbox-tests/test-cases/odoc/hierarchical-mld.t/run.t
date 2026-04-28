Test hierarchical mld files (mlds in subdirectories)

  $ dune build @doc
  File "_index/index.mld", line 3, characters 2-29:
  Warning: Failed to resolve reference /mypkg/index Path '/mypkg/index' not found
  File "../doc/mypkg.mld", line 7, characters 9-50:
  Warning: Failed to resolve reference unresolvedroot(getting-started) Couldn't find page "getting-started"
  File "../doc/mypkg.mld", line 6, characters 5-45:
  Warning: Failed to resolve reference ./tutorial/getting-started Path 'tutorial/getting-started' not found
  File "../doc/mypkg.mld", line 5, characters 23-70:
  Warning: Failed to resolve reference /mypkg/tutorial/getting-started Path '/mypkg/tutorial/getting-started' not found
  File "../doc/mypkg.mld", line 4, characters 10-55:
  Warning: Failed to resolve reference //tutorial/getting-started Path '//tutorial/getting-started' not found

Check what HTML was generated - hierarchical pages ARE supported:

  $ ls _build/default/_doc/_html/mypkg/
  index.html
  mypkg.html
  tutorial

  $ ls _build/default/_doc/_html/mypkg/tutorial/
  getting-started.html

Verify the content was rendered:

  $ cat _build/default/_doc/_html/mypkg/tutorial/getting-started.html | grep -o 'Getting Started'
  Getting Started

Verify the cross-references from mypkg.mld to the tutorial page resolved correctly:

  $ grep -o 'href="[^"]*getting-started[^"]*"' _build/default/_doc/_html/mypkg/mypkg.html
  [1]

The intentionally broken reference (without tutorial/ path) shows as unresolved:

  $ grep -o 'xref-unresolved[^>]*>[^<]*' _build/default/_doc/_html/mypkg/mypkg.html
  xref-unresolved" title="//tutorial/getting-started">subpage
  xref-unresolved" title="/mypkg/tutorial/getting-started">this
  xref-unresolved" title="./tutorial/getting-started">this
  xref-unresolved" title="getting-started">shouldn't work
