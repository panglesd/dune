This tests shows how to use the `dune ocaml doc` command to open the
documentation index to a browser.
  $ if [ "$(uname)" = Darwin ]; then mv xdg-open open; fi
  $ export PATH=.:$PATH 
  $ dune ocaml doc
  File "_index/index.mld", line 3, characters 2-25:
  Warning: Failed to resolve reference /foo/index Path '/foo/index' not found
  Docs built. Index can be found here: _build/default/_doc/_html/index.html
  open command received args:
  _build/default/_doc/_html/index.html
