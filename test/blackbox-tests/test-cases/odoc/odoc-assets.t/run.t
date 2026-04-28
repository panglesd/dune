Test that odoc assets (images, etc.) are properly processed:

  $ dune build @doc
  File "_doc/_odoc/mylib/_unknown_", line 1, characters 0-0:
  ERROR: Unknown extension, expected one of: cmti, cmt, cmi or mld.
  [1]

Verify the asset .odocl file was compiled:

  $ find _build/default/_doc/_odocls/mylib -name '*.odocl' | sort
  find: '_build/default/_doc/_odocls/mylib': No such file or directory
  [1]

Verify the asset was copied to HTML output:

  $ test -f _build/default/_doc/_html/mylib/logo.png && echo "logo.png exists in HTML output"
  [1]

Verify the index.html references the asset:

  $ test -f _build/default/_doc/_html/mylib/index.html && echo "index.html exists"
  [1]

Test that @doc-full also works with assets:

  $ dune build @doc-full
  File "_doc/_odoc/mylib/_unknown_", line 1, characters 0-0:
  ERROR: Unknown extension, expected one of: cmti, cmt, cmi or mld.
  [1]

Verify asset was copied to HTML full output:

  $ test -f _build/default/_doc/_html_full/mylib/logo.png && echo "logo.png exists in HTML full output"
  [1]

Test that @doc-json also works with assets (assets are copied to JSON output):

  $ dune build @doc-json
  File "_doc/_odoc/mylib/_unknown_", line 1, characters 0-0:
  ERROR: Unknown extension, expected one of: cmti, cmt, cmi or mld.
  [1]

Verify JSON files are generated:

  $ find _build/default/_doc/_json/mylib -name '*.json' | sort
  find: '_build/default/_doc/_json/mylib': No such file or directory
  [1]

Verify the asset was copied to JSON output:

  $ test -f _build/default/_doc/_json/mylib/logo.png && echo "logo.png exists in JSON output"
  [1]

Test that @doc-json-full also works with assets:

  $ dune build @doc-json-full
  File "_doc/_odoc/mylib/_unknown_", line 1, characters 0-0:
  ERROR: Unknown extension, expected one of: cmti, cmt, cmi or mld.
  [1]

Verify asset was copied to JSON full output:

  $ test -f _build/default/_doc/_json_full/mylib/logo.png && echo "logo.png exists in JSON full output"
  [1]
