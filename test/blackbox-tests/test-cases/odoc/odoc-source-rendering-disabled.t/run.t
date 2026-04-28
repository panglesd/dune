Source rendering disabled test - verify impl artifacts are NOT generated:

  $ dune build @doc 2>&1 | head -20
  File "dune", line 8, characters 4-20:
  8 |    (source_rendering disabled))))
          ^^^^^^^^^^^^^^^^
  Error: Unknown field "source_rendering"
  [1]

Check that NO impl .odoc files are generated:

  $ find _build/default/_doc/_odoc -name 'impl-*' 2>/dev/null | sort
  [1]

Check that NO impl .odocl files are generated:

  $ find _build/default/_doc/_odocls -name 'impl-*' 2>/dev/null | sort
  [1]

Check that NO source HTML is generated (no .ml.html files):

  $ find _build/default/_doc/_html -name '*.ml.html' 2>/dev/null | sort
  [1]

Module documentation should still be generated:

  $ find _build/default/_doc/_html -name '*.html' | sort
  find: '_build/default/_doc/_html': No such file or directory
  [1]
