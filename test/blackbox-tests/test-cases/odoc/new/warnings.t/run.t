  $ export BUILD_PATH_PREFIX_MAP=odoc=`command -v odoc`

As configured in the `dune` file at the root, this should be an error:

  $ dune build --only-packages=foo_doc @doc-new
  Error: No rule found for _doc_new/html/docs.html
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  File "../../../../foo_doc/foo.mld", line 4, characters 0-0:
  Error: End of text is not allowed in '[...]' (code).
  ERROR: Warnings have been generated.
  [1]

Same for documentation in mli files:

  $ dune build --only-packages=foo_lib @doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/html/local/foo_lib/foo_lib.html:
  - <internal location>
  - <internal location>
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/odoc/local/foo_lib/foo_lib.mld:
  - <internal location>
  - <internal location>
  -> required by _build/default/_doc_new/html/db.js
  -> required by
     _build/default/_doc_new/html/stdlib/CamlinternalFormat/index.html
  -> required by alias _doc_new/html/stdlib/doc-new
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: No rule found for _doc_new/html/docs.html
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  [1]

These packages are in a nested env, the option is disabled, should success with warning printed:

  $ dune build --only-packages=bar_doc,bar_lib @doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/html/local/bar_lib/bar_lib.html:
  - <internal location>
  - <internal location>
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/odoc/local/bar_lib/bar_lib.mld:
  - <internal location>
  - <internal location>
  -> required by _build/default/_doc_new/html/db.js
  -> required by _build/default/_doc_new/html/local/bar_doc/bar.html
  -> required by alias _doc_new/html/local/bar_doc/doc-new
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: No rule found for _doc_new/html/docs.html
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  File "../../../../sub_env/bar_doc/bar.mld", line 4, characters 0-0:
  Error: End of text is not allowed in '[...]' (code).
  ERROR: Warnings have been generated.
  [1]

In release mode, no error:

  $ dune build -p foo_doc,foo_lib @doc-new
  (cd _build/default/_doc_new/odoc/local/foo_doc && odoc compile -o page-foo.odoc ../../../../foo_doc/foo.mld --output-dir ../.. --parent-id local/foo_doc)
  File "../../../../foo_doc/foo.mld", line 4, characters 0-0:
  Warning: End of text is not allowed in '[...]' (code).
  Error: Multiple rules generated for
  _build/default/_doc_new/html/local/foo_lib/foo_lib.html:
  - <internal location>
  - <internal location>
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/odoc/local/foo_lib/foo_lib.mld:
  - <internal location>
  - <internal location>
  -> required by _build/default/_doc_new/html/db.js
  -> required by _build/default/_doc_new/html/local/foo_doc/foo.html
  -> required by alias _doc_new/html/local/foo_doc/doc-new
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: No rule found for _doc_new/html/docs.html
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  [1]
