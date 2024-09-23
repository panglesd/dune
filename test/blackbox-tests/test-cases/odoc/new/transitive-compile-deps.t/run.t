This test checks that compilation dependencies are correct

  $ dune build @doc-new
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/odoctest3/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/odoctest3/page-odoctest3.odoc
  File "_doc_new/odoc/local/odoctest3/sublib1/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/odoctest3/sublib1/page-sublib1.odoc
  File "_doc_new/odoc/local/odoctest3/sublib2/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/odoctest3/sublib2/page-sublib2.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/camlinternalFormatBasics.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/page-stdlib.odoc
  [1]

There should be an expansion of S:

  $ ls _build/default/_doc_new/html/docs/local/odoctest3/Odoctest3/C/
  ls: cannot access '_build/default/_doc_new/html/docs/local/odoctest3/Odoctest3/C/': No such file or directory
  [2]
