Duplicate mld's in the same scope
  $ dune build @doc
  File "_index/index.mld", line 3, characters 2-27:
  Warning: Failed to resolve reference /root/index Path '/root/index' not found
  Error: Package root has two mld's with the same basename
  _build/default/lib2/test.mld, _build/default/lib1/test.mld
  -> required by alias doc
  [1]
