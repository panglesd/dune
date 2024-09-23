This test checks that there is no clash when two private libraries have the same name

  $ dune build --display short @doc-new 2>&1 | grep docs/test
  [1]
