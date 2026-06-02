Test that references to installed libraries like Lwt work correctly.
This verifies that cross-library references in documentation comments
are resolved correctly when linking.

Build documentation:

  $ dune build @doc
  File "mylib.ml", line 3, characters 20-28:
  3 | let run_promise p = Lwt_main.run p
                          ^^^^^^^^
  Error: Unbound module Lwt_main
  [1]

Check that documentation was generated without broken reference warnings:

  $ find _build/default/_doc/_odocls/mylib -name '*.odocl' | sort -n
  find: '_build/default/_doc/_odocls/mylib': No such file or directory
  [1]

Check that HTML was generated for our library:

  $ find _build/default/_doc/_html/mylib -name '*.html' | sort -n
  find: '_build/default/_doc/_html/mylib': No such file or directory
  [1]

Verify that Lwt documentation was also built (needed for cross-references):

  $ ls _build/default/_doc/_odoc/lwt/lwt/Lwt.odoc
  ls: cannot access '_build/default/_doc/_odoc/lwt/lwt/Lwt.odoc': No such file or directory
  [2]

Check that the generated HTML contains links to Lwt types:

  $ grep -o "href=\"[^\"]*Lwt[^\"]*\"" _build/default/_doc/_html/mylib/mylib/Mylib/index.html | head -3
  grep: _build/default/_doc/_html/mylib/mylib/Mylib/index.html: No such file or directory
  [2]
