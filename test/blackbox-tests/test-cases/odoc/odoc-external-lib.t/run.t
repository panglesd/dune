External (installed) libraries can have their `.odoc` files compiled, into
`_doc/_odoc/<lib-name>`. Here we compile the documentation of the `unix`
library that `mylib` depends on.

odoc emits version-specific warnings about `unix.mli`'s documentation comments,
so we discard stderr and just check that the `.odoc` files are produced.

  $ dune build _doc/_odoc/unix/unix.odoc _doc/_odoc/unix/unixLabels.odoc 2>/dev/null

  $ find _build/default/_doc/_odoc/unix -name '*.odoc' | sort
  _build/default/_doc/_odoc/unix/unix.odoc
  _build/default/_doc/_odoc/unix/unixLabels.odoc

The classify output that drives external module discovery lists the library's
archive and its modules:

  $ cat _build/default/_doc/_classify/unix/odoc.classify
  unix Unix UnixLabels
