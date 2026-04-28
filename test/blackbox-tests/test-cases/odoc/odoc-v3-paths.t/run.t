Test that a specific odoc v3 file can be built directly

  $ dune build _build/default/_doc/_odoc/foo/foo/foo.odoc
  Error: Don't know how to build _build/default/_doc/_odoc/foo/foo/foo.odoc
  [1]
  $ ls _build/default/_doc/_odoc/foo/foo/
  ls: cannot access '_build/default/_doc/_odoc/foo/foo/': No such file or directory
  [2]

Verify the odoc file was compiled with v3 flags (--parent-id and --output-dir)

  $ dune clean
  $ dune build _build/default/_doc/_odoc/foo/foo/foo.odoc --verbose 2>&1 | grep -o "\-\-output-dir [^ ]* \-\-parent-id foo/foo"
  [1]

Test that odocl files are generated in v3 structure

  $ dune build _build/default/_doc/_odocls/foo/foo/foo.odocl
  Error: Don't know how to build _build/default/_doc/_odocls/foo/foo/foo.odocl
  [1]
  $ ls _build/default/_doc/_odocls/foo/foo/
  ls: cannot access '_build/default/_doc/_odocls/foo/foo/': No such file or directory
  [2]

Test that HTML files are generated in v3 structure

  $ dune build _build/default/_doc/_html/foo/foo/Foo/index.html
  Error: Don't know how to build
  _build/default/_doc/_html/foo/foo/Foo/index.html
  [1]
  $ ls _build/default/_doc/_html/foo/foo/Foo/
  ls: cannot access '_build/default/_doc/_html/foo/foo/Foo/': No such file or directory
  [2]
