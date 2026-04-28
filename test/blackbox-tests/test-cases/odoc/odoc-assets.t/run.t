Test that odoc assets (images, etc.) are properly processed:

  $ dune build @doc
  File "../index.mld", line 7, characters 0-23:
  Warning: Failed to resolve reference /mylib/logo.png Path '/mylib/logo.png' not found

Verify the asset .odocl file was compiled:

  $ find _build/default/_doc/_odocls/mylib -name '*.odocl' | sort
  _build/default/_doc/_odocls/mylib/mylib/mylib.odocl
  _build/default/_doc/_odocls/mylib/mylib/page-index.odocl
  _build/default/_doc/_odocls/mylib/page-index.odocl

Verify the asset was copied to HTML output:

  $ test -f _build/default/_doc/_html/mylib/logo.png && echo "logo.png exists in HTML output"
  [1]

Verify the index.html references the asset:

  $ test -f _build/default/_doc/_html/mylib/index.html && echo "index.html exists"
  index.html exists

Test that @doc-full also works with assets:

  $ dune build @doc-full

Verify asset was copied to HTML full output:

  $ test -f _build/default/_doc/_html_full/mylib/logo.png && echo "logo.png exists in HTML full output"
  [1]

Test that @doc-json also works with assets (assets are copied to JSON output):

  $ dune build @doc-json

Verify JSON files are generated:

  $ find _build/default/_doc/_json/mylib -name '*.json' | sort
  _build/default/_doc/_json/mylib/index.html.json
  _build/default/_doc/_json/mylib/mylib/Mylib/index.html.json
  _build/default/_doc/_json/mylib/mylib/index.html.json

Verify the asset was copied to JSON output:

  $ test -f _build/default/_doc/_json/mylib/logo.png && echo "logo.png exists in JSON output"
  [1]

Test that @doc-json-full also works with assets:

  $ dune build @doc-json-full

Verify asset was copied to JSON full output:

  $ test -f _build/default/_doc/_json_full/mylib/logo.png && echo "logo.png exists in JSON full output"
  [1]
