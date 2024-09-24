Make sure that links between mld files are resolved even when there is
no library associated with the project

This test case is based on code provided by @vphantom, ocaml/dune#2007

  $ dune build @doc-new --verbose
  Shared cache: enabled
  Shared cache location: /home/panglesd/.cache/dune/db
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
  Argh lib ex loc: stdlib
  Argh lib ex loc: stdlib
  Argh lib ex loc: stdlib
  Argh lib ex loc: stdlib
  Running[1]: (cd _build/default/_doc_new/odoc/local/odoc_page_link_bug && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-otherpage.odoc ../../../../otherpage.mld --output-dir ../.. --parent-id local/odoc_page_link_bug)
  Running[2]: (cd _build/default/_doc_new/odoc/local/odoc_page_link_bug && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-odoc_page_link_bug.odoc odoc_page_link_bug.mld --output-dir ../.. --parent-id local/odoc_page_link_bug)
  Running[3]: (cd _build/default/_doc_new/odoc/local && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-local.odoc local.mld --output-dir .. --parent-id local)
  Running[4]: (cd _build/default/_doc_new/odoc && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-docs.odoc docs.mld --output-dir . --parent-id '')
  Running[5]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_build/default/test/blackbox-tests/test-cases/.bin/sherlodoc js sherlodoc.js)
  Running[6]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/odoc support-files -o _doc_new/html/docs/odoc.support)
  Running[7]: (cd _build/default/_doc_new/odoc/local/odoc_page_link_bug && /home/panglesd/code/dune/_opam/bin/odoc link -I . -I ../../other/stdlib -o page-otherpage.odocl page-otherpage.odoc)
  Running[8]: (cd _build/default/_doc_new/odoc/local/odoc_page_link_bug && /home/panglesd/code/dune/_opam/bin/odoc link -I . -I ../../other/stdlib -o page-odoc_page_link_bug.odocl page-odoc_page_link_bug.odoc)
  Running[9]: (cd _build/default/_doc_new/odoc/local && /home/panglesd/code/dune/_opam/bin/odoc link -I odoc_page_link_bug -I ../other/stdlib -o page-local.odocl page-local.odoc)
  Running[10]: (cd _build/default/_doc_new/odoc && /home/panglesd/code/dune/_opam/bin/odoc link -I local -I local/odoc_page_link_bug -I other/stdlib -o page-docs.odocl page-docs.odoc)
  Running[11]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_build/default/test/blackbox-tests/test-cases/.bin/sherlodoc index --favoured ../odoc/local/odoc_page_link_bug/page-odoc_page_link_bug.odocl --favoured ../odoc/local/odoc_page_link_bug/page-otherpage.odocl --favoured ../odoc/local/page-local.odocl --favoured ../odoc/page-docs.odocl --favoured-prefixes '""' --format=js --db db.js)
  Running[12]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/page-docs.odocl)
  Running[13]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/local/page-local.odocl)
  Running[14]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/local/odoc_page_link_bug/page-odoc_page_link_bug.odocl)
  Running[15]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/local/odoc_page_link_bug/page-otherpage.odocl)

  $ cp -r _build/default/_doc_new /tmp/docnew

  $ find _build/default/_doc_new -name local.html
  _build/default/_doc_new/html/local/local.html
  $ ls _build/default/_doc_new/html/docs/local/local.html
  ls: cannot access '_build/default/_doc_new/html/docs/local/local.html': No such file or directory
  [2]

  $ grep -r xref-unresolved _build/default/_doc_new/html/docs/local/odoc_page_link_bug/index.html
  grep: _build/default/_doc_new/html/docs/local/odoc_page_link_bug/index.html: No such file or directory
  [2]
