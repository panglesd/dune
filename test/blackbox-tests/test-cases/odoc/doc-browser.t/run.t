This tests shows how to use the `dune ocaml doc` command to open the
documentation index to a browser.
  $ if [ "$(uname)" = Darwin ]; then mv xdg-open open; fi
  $ export PATH=.:$PATH 
  $ dune ocaml doc
  File "_doc/_odocls/foo/_unknown_", line 1, characters 0-0:
  Error: No rule found for alias _doc/_odoc/foo/.odoc-all
  [1]
