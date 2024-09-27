Make sure that links between mld files are resolved even when there is
no library associated with the project

This test case is based on code provided by @vphantom, ocaml/dune#2007

  $ dune build @doc-new --verbose
  Shared cache: enabled
  Shared cache location: /home/emile/.cache/dune/db
  Workspace root:
  $TESTCASE_ROOT
  Dune context:
   { name = "default"
   ; kind = "default"
   ; profile = Dev
   ; merlin = true
   ; fdo_target_exe = None
   ; build_dir = In_build_dir "default"
   ; instrument_with = []
   }
  Actual targets:
  - recursive alias @doc-new
  Running[1]: (cd _build/default && /home/emile/.opam/sherlodoc/bin/odoc support-files -o _doc_new/html/docs/odoc.support)
  Argh lib ex loc: stdlib
  Argh lib ex loc: stdlib
  Running[2]: (cd _build/default/_doc_new/odoc/local/odoc_page_link_bug && /home/emile/.opam/sherlodoc/bin/odoc compile -o page-otherpage.odoc ../../../../otherpage.mld --output-dir ../.. --parent-id local/odoc_page_link_bug)
  Running[3]: (cd _build/default/_doc_new/odoc/local/odoc_page_link_bug && /home/emile/.opam/sherlodoc/bin/odoc compile -o page-odoc_page_link_bug.odoc odoc_page_link_bug.mld --output-dir ../.. --parent-id local/odoc_page_link_bug)
  Running[4]: (cd _build/default/_doc_new/html && /home/emile/Projects/ocaml/dune/_build/default/test/blackbox-tests/test-cases/.bin/sherlodoc js sherlodoc.js)
  Running[5]: (cd _build/default/_doc_new/odoc/local/odoc_page_link_bug && /home/emile/.opam/sherlodoc/bin/odoc link -I . -I ../../other/stdlib -o page-otherpage.odocl page-otherpage.odoc)
  Running[6]: (cd _build/default/_doc_new/odoc/local/odoc_page_link_bug && /home/emile/.opam/sherlodoc/bin/odoc link -I . -I ../../other/stdlib -o page-odoc_page_link_bug.odocl page-odoc_page_link_bug.odoc)
  Running[7]: (cd _build/default/_doc_new/html && /home/emile/Projects/ocaml/dune/_build/default/test/blackbox-tests/test-cases/.bin/sherlodoc index --favoured ../odoc/local/odoc_page_link_bug/page-odoc_page_link_bug.odocl --favoured ../odoc/local/odoc_page_link_bug/page-otherpage.odocl --favoured-prefixes '""' --format=js --db db.js)
  Running[8]: (cd _build/default/_doc_new/html && /home/emile/.opam/sherlodoc/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/local/odoc_page_link_bug/page-odoc_page_link_bug.odocl)
  Running[9]: (cd _build/default/_doc_new/html && /home/emile/.opam/sherlodoc/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/local/odoc_page_link_bug/page-otherpage.odocl)
  Error: No rule found for _doc_new/html/docs.html
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  [1]

  $ cp -r _build/default/_doc_new /tmp/docnew

  $ find _build/default/_doc_new -name local.html
  $ ls _build/default/_doc_new/html/docs/local/local.html
  ls: cannot access '_build/default/_doc_new/html/docs/local/local.html': No such file or directory
  [2]

  $ grep -r xref-unresolved _build/default/_doc_new/html/docs/local/odoc_page_link_bug/index.html
  grep: _build/default/_doc_new/html/docs/local/odoc_page_link_bug/index.html: No such file or directory
  [2]
