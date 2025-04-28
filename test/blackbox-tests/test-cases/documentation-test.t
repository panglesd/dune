Test the error cases for dune's Ordered Set Language (OSL) DSL.

  $ cat > dune-project <<EOF
  > (lang dune 3.14)
  > (package
  >  (name rien)
  >  (doc_depends
  >    (packages blibli blublu)))
  > (generate_opam_files true)
  > EOF

  $ cat > foo.mld <<EOF
  > let () = print_endline "foo"
  > EOF

  $ touch bli.jpg
  $ mkdir prout
  $ touch prout/foo2.mld


Make a dune file and build the project, using the "flags" field to exercise OSL.
  $ cat > dune <<EOF
  > ; (include_subdirs as_documentation)
  > ; (library (name rien))
  > (documentation
  >  (mld_files foo)
  >  (files (glob_files_rec prout/*))
  >  (path test)
  >  )
  > EOF
  $ dune build -p rien @install @all
  from _build/default : _build/default/prout/foo2.mld -> _build/default/prout/foo2.mld
  from _build/default : _build/default/foo.mld -> _build/default/foo.mld

  $ cat rien.install
  lib: [
    "_build/install/default/lib/rien/META"
    "_build/install/default/lib/rien/dune-package"
    "_build/install/default/lib/rien/opam"
  ]
  doc: [
    "_build/install/default/doc/rien/odoc-config.sexp"
    "_build/install/default/doc/rien/odoc-pages/test/foo.mld" {"odoc-pages/test/foo.mld"}
    "_build/install/default/doc/rien/odoc-pages/test/prout/foo2.mld" {"odoc-pages/test/prout/foo2.mld"}
  ]

  $ ls -R _build/
  _build/:
  default
  install
  log
  
  _build/default:
  META.rien
  foo.mld
  prout
  rien.dune-package
  rien.install
  rien.odoc-config.sexp
  rien.opam
  
  _build/default/prout:
  foo2.mld
  
  _build/install:
  default
  
  _build/install/default:
  doc
  lib
  
  _build/install/default/doc:
  rien
  
  _build/install/default/doc/rien:
  odoc-config.sexp
  odoc-pages
  
  _build/install/default/doc/rien/odoc-pages:
  test
  
  _build/install/default/doc/rien/odoc-pages/test:
  foo.mld
  prout
  
  _build/install/default/doc/rien/odoc-pages/test/prout:
  foo2.mld
  
  _build/install/default/lib:
  rien
  
  _build/install/default/lib/rien:
  META
  dune-package
  opam

  $ cat _build/install/default/doc/rien/odoc-config.sexp
  (libraries )
  (packages blibli blublu)


  $ dune build @doc --verbose
  Shared cache: enabled-except-user-rules
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
  - recursive alias @doc
  from _build/default : _build/default/prout/foo2.mld -> _build/default/prout/foo2.mld
  from _build/default : _build/default/foo.mld -> _build/default/foo.mld
  Running[1]: (cd _build/default && /home/panglesd/.opam/5.2.0/bin/odoc support-files -o _doc/_html/odoc.support)
  Running[2]: (cd _build/default/_doc/_odoc/pkg/rien && /home/panglesd/.opam/5.2.0/bin/odoc compile --output-dir ./ --parent-id '' -o page-foo.odoc ../../../../foo.mld)
  Output[2]:
  File "foo.mld":
  Warning: Pages (.mld files) should start with a heading.
  Running[3]: (cd _build/default/_doc/_odoc/pkg/rien && /home/panglesd/.opam/5.2.0/bin/odoc compile --output-dir ./ --parent-id '' -o page-foo2.odoc ../../../../prout/foo2.mld)
  Running[4]: (cd _build/default/_doc/_odoc/pkg/rien && /home/panglesd/.opam/5.2.0/bin/odoc compile --output-dir ./ --parent-id '' -o page-index.odoc ../../../_mlds/rien/index.mld)
  Running[5]: (cd _build/default/_doc/_html && /home/panglesd/code/dune/_build/default/test/blackbox-tests/test-cases/.bin/sherlodoc js sherlodoc.js)
  Running[6]: (cd _build/default/_doc/_html && /home/panglesd/.opam/5.2.0/bin/odoc link -I ../_odoc/pkg/rien -o ../_odocls/rien/page-foo.odocl ../_odoc/pkg/rien/page-foo.odoc)
  Running[7]: (cd _build/default/_doc/_html && /home/panglesd/.opam/5.2.0/bin/odoc link -I ../_odoc/pkg/rien -o ../_odocls/rien/page-foo2.odocl ../_odoc/pkg/rien/page-foo2.odoc)
  Running[8]: (cd _build/default/_doc/_html && /home/panglesd/.opam/5.2.0/bin/odoc link -I ../_odoc/pkg/rien -o ../_odocls/rien/page-index.odocl ../_odoc/pkg/rien/page-index.odoc)
  Running[9]: (cd _build/default/_doc/_html/rien && /home/panglesd/code/dune/_build/default/test/blackbox-tests/test-cases/.bin/sherlodoc index --favoured ../../_odocls/rien/page-foo.odocl --favoured ../../_odocls/rien/page-foo2.odocl --favoured ../../_odocls/rien/page-index.odocl --favoured-prefixes '""' --format=js --db db.js)
  Running[10]: (cd _build/default/_doc/_html && /home/panglesd/.opam/5.2.0/bin/odoc html-generate --search-uri rien/db.js --search-uri sherlodoc.js -o . --support-uri odoc.support --theme-uri odoc.support ../_odocls/rien/page-foo.odocl)
  Running[11]: (cd _build/default/_doc/_html && /home/panglesd/.opam/5.2.0/bin/odoc html-generate --search-uri rien/db.js --search-uri sherlodoc.js -o . --support-uri odoc.support --theme-uri odoc.support ../_odocls/rien/page-foo2.odocl)
  Running[12]: (cd _build/default/_doc/_html && /home/panglesd/.opam/5.2.0/bin/odoc html-generate --search-uri rien/db.js --search-uri sherlodoc.js -o . --support-uri odoc.support --theme-uri odoc.support ../_odocls/rien/page-index.odocl)
  File "_doc/_html/rien/_unknown_", line 1, characters 0-0:
  Command [12] exited with code 2:
  $ (cd _build/default/_doc/_html && /home/panglesd/.opam/5.2.0/bin/odoc html-generate --search-uri rien/db.js --search-uri sherlodoc.js -o . --support-uri odoc.support --theme-uri odoc.support ../_odocls/rien/page-index.odocl)
  odoc: internal error, uncaught exception:
        Sys_error("index.html: Permission denied")
        Raised by primitive operation at Stdlib.open_out_gen in file "stdlib.ml", line 331, characters 29-55
        Called from Stdlib.open_out in file "stdlib.ml" (inlined), line 336, characters 2-74
        Called from Odoc_odoc__Rendering.render_document.(fun) in file "src/odoc/rendering.ml", line 55, characters 15-52
        Called from Odoc_document__Renderer.traverse.aux in file "src/document/renderer.ml", line 16, characters 4-32
        Called from Stdlib__List.iter in file "list.ml", line 112, characters 12-15
        Called from Odoc_odoc__Rendering.generate_odoc.(fun) in file "src/odoc/rendering.ml", line 74, characters 2-68
        Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 24, characters 19-24
        Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 22, characters 12-19
        Called from Cmdliner_eval.run_parser in file "cmdliner_eval.ml", line 35, characters 37-44
  File "_doc/_html/rien/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc/_html/rien/foo.html
  File "_doc/_html/rien/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc/_html/rien/foo2.html
  [1]
  $ (cd _build/default/_doc/_html && /home/panglesd/.opam/5.2.0/bin/odoc html-generate --search-uri rien/db.js --search-uri sherlodoc.js -o . --support-uri odoc.support --theme-uri odoc.support ../_odocls/rien/page-index.odocl)
  odoc: internal error, uncaught exception:
        Sys_error("index.html: Permission denied")
        Raised by primitive operation at Stdlib.open_out_gen in file "stdlib.ml", line 331, characters 29-55
        Called from Stdlib.open_out in file "stdlib.ml" (inlined), line 336, characters 2-74
        Called from Odoc_odoc__Rendering.render_document.(fun) in file "src/odoc/rendering.ml", line 55, characters 15-52
        Called from Odoc_document__Renderer.traverse.aux in file "src/document/renderer.ml", line 16, characters 4-32
        Called from Stdlib__List.iter in file "list.ml", line 112, characters 12-15
        Called from Odoc_odoc__Rendering.generate_odoc.(fun) in file "src/odoc/rendering.ml", line 74, characters 2-68
        Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 24, characters 19-24
        Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 22, characters 12-19
        Called from Cmdliner_eval.run_parser in file "cmdliner_eval.ml", line 35, characters 37-44
  [2]

  $ tree _build/default/_doc
  _build/default/_doc
  |-- _html
  |   |-- foo.html
  |   |-- foo2.html
  |   |-- index.html
  |   |-- odoc.support
  |   |   |-- fonts
  |   |   |   |-- KaTeX_AMS-Regular.woff2
  |   |   |   |-- KaTeX_Caligraphic-Bold.woff2
  |   |   |   |-- KaTeX_Caligraphic-Regular.woff2
  |   |   |   |-- KaTeX_Fraktur-Bold.woff2
  |   |   |   |-- KaTeX_Fraktur-Regular.woff2
  |   |   |   |-- KaTeX_Main-Bold.woff2
  |   |   |   |-- KaTeX_Main-BoldItalic.woff2
  |   |   |   |-- KaTeX_Main-Italic.woff2
  |   |   |   |-- KaTeX_Main-Regular.woff2
  |   |   |   |-- KaTeX_Math-BoldItalic.woff2
  |   |   |   |-- KaTeX_Math-Italic.woff2
  |   |   |   |-- KaTeX_SansSerif-Bold.woff2
  |   |   |   |-- KaTeX_SansSerif-Italic.woff2
  |   |   |   |-- KaTeX_SansSerif-Regular.woff2
  |   |   |   |-- KaTeX_Script-Regular.woff2
  |   |   |   |-- KaTeX_Size1-Regular.woff2
  |   |   |   |-- KaTeX_Size2-Regular.woff2
  |   |   |   |-- KaTeX_Size3-Regular.woff2
  |   |   |   |-- KaTeX_Size4-Regular.woff2
  |   |   |   |-- KaTeX_Typewriter-Regular.woff2
  |   |   |   |-- fira-mono-v14-latin-500.woff2
  |   |   |   |-- fira-mono-v14-latin-regular.woff2
  |   |   |   |-- fira-sans-v17-latin-500.woff2
  |   |   |   |-- fira-sans-v17-latin-500italic.woff2
  |   |   |   |-- fira-sans-v17-latin-700.woff2
  |   |   |   |-- fira-sans-v17-latin-700italic.woff2
  |   |   |   |-- fira-sans-v17-latin-italic.woff2
  |   |   |   |-- fira-sans-v17-latin-regular.woff2
  |   |   |   |-- noticia-text-v15-latin-700.woff2
  |   |   |   |-- noticia-text-v15-latin-italic.woff2
  |   |   |   `-- noticia-text-v15-latin-regular.woff2
  |   |   |-- highlight.pack.js
  |   |   |-- katex.min.css
  |   |   |-- katex.min.js
  |   |   |-- odoc.css
  |   |   `-- odoc_search.js
  |   |-- rien
  |   |   `-- db.js
  |   `-- sherlodoc.js
  |-- _mlds
  |   `-- rien
  |       `-- index.mld
  |-- _odoc
  |   `-- pkg
  |       `-- rien
  |           |-- page-foo.odoc
  |           |-- page-foo2.odoc
  |           `-- page-index.odoc
  `-- _odocls
      `-- rien
          |-- page-foo.odocl
          |-- page-foo2.odocl
          `-- page-index.odocl
  
  12 directories, 48 files
