This test checks that compilation dependencies are correct

  $ dune build @doc-new
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/odoctest2/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/odoctest2/page-odoctest2.odoc
  File "_doc_new/odoc/local/odoctest2/sublib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/odoctest2/sublib/page-sublib.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/camlinternalFormatBasics.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/page-stdlib.odoc
  [1]

There should be an expansion of `B.Foo` - ie, a directory called `Foo`:

  $ ls _build/default/_doc_new/html/docs/local/odoctest2/Odoctest2/B
  ls: cannot access '_build/default/_doc_new/html/docs/local/odoctest2/Odoctest2/B': No such file or directory
  [2]
