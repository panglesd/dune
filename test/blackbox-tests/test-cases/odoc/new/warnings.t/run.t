  $ export BUILD_PATH_PREFIX_MAP=odoc=`command -v odoc`

As configured in the `dune` file at the root, this should be an error:

  $ dune build --only-packages=foo_doc @doc-new
  File "../../../../foo_doc/foo.mld", line 4, characters 0-0:
  Error: End of text is not allowed in '[...]' (code).
  ERROR: Warnings have been generated.
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/foo_doc/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/foo_doc/page-foo_doc.odoc
  [1]

Same for documentation in mli files:

  $ dune build --only-packages=foo_lib @doc-new
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/foo_lib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/foo_lib/page-foo_lib.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/camlinternalFormatBasics.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/page-stdlib.odoc
  [1]

These packages are in a nested env, the option is disabled, should success with warning printed:

  $ dune build --only-packages=bar_doc,bar_lib @doc-new
  File "../../../../sub_env/bar_doc/bar.mld", line 4, characters 0-0:
  Error: End of text is not allowed in '[...]' (code).
  ERROR: Warnings have been generated.
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/bar_doc/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/bar_doc/page-bar_doc.odoc
  File "_doc_new/odoc/local/bar_lib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/bar_lib/page-bar_lib.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/camlinternalFormatBasics.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/page-stdlib.odoc
  [1]

In release mode, no error:

  $ dune build -p foo_doc,foo_lib @doc-new
  (cd _build/default/_doc_new/odoc/local/foo_doc && odoc compile -o page-foo.odoc ../../../../foo_doc/foo.mld --output-dir ../.. --parent-id local/foo_doc/foo_doc)
  File "../../../../foo_doc/foo.mld", line 4, characters 0-0:
  Warning: End of text is not allowed in '[...]' (code).
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/foo_doc/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/foo_doc/page-foo.odoc
  File "_doc_new/odoc/local/foo_doc/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/foo_doc/page-foo_doc.odoc
  File "_doc_new/odoc/local/foo_lib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/foo_lib/page-foo_lib.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/camlinternalFormatBasics.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/page-stdlib.odoc
  [1]
