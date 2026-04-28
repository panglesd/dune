Duplicate mld's in the same scope
  $ dune build @doc
  Error: Package root has two mld's with the same basename
  _build/default/lib2/test.mld, _build/default/lib1/test.mld
  -> required by alias _doc/_html/doc
  -> required by alias doc
  [1]
