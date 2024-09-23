Check that a type path referring to Stdlib.Format is resolved:

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
  Running[1]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalFormat.cmti) > _build/default/_doc_new/odoc/stdlib/camlinternalFormat.deps
  Running[2]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalFormatBasics.cmti) > _build/default/_doc_new/odoc/stdlib/camlinternalFormatBasics.deps
  Running[3]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalLazy.cmti) > _build/default/_doc_new/odoc/stdlib/camlinternalLazy.deps
  Running[4]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalMod.cmti) > _build/default/_doc_new/odoc/stdlib/camlinternalMod.deps
  Running[5]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalOO.cmti) > _build/default/_doc_new/odoc/stdlib/camlinternalOO.deps
  Running[6]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/std_exit.cmti) > _build/default/_doc_new/odoc/stdlib/std_exit.deps
  Running[7]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib.deps
  Running[8]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Arg.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Arg.deps
  Running[9]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Array.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Array.deps
  Running[10]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__ArrayLabels.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__ArrayLabels.deps
  Running[11]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Atomic.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Atomic.deps
  Running[12]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Bigarray.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Bigarray.deps
  Running[13]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Bool.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Bool.deps
  Running[14]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Buffer.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Buffer.deps
  Running[15]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Bytes.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Bytes.deps
  Running[16]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__BytesLabels.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__BytesLabels.deps
  Running[17]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Callback.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Callback.deps
  Running[18]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Char.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Char.deps
  Running[19]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Complex.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Complex.deps
  Running[20]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Condition.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Condition.deps
  Running[21]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Digest.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Digest.deps
  Running[22]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Domain.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Domain.deps
  Running[23]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Effect.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Effect.deps
  Running[24]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Either.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Either.deps
  Running[25]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Ephemeron.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Ephemeron.deps
  Running[26]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Filename.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Filename.deps
  Running[27]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Float.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Float.deps
  Running[28]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Format.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Format.deps
  Running[29]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Fun.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Fun.deps
  Running[30]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Gc.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Gc.deps
  Running[31]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Hashtbl.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Hashtbl.deps
  Running[32]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__In_channel.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__In_channel.deps
  Running[33]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Int.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Int.deps
  Running[34]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Int32.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Int32.deps
  Running[35]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Int64.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Int64.deps
  Running[36]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Lazy.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Lazy.deps
  Running[37]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Lexing.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Lexing.deps
  Running[38]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__List.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__List.deps
  Running[39]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__ListLabels.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__ListLabels.deps
  Running[40]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Map.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Map.deps
  Running[41]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Marshal.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Marshal.deps
  Running[42]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__MoreLabels.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__MoreLabels.deps
  Running[43]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Mutex.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Mutex.deps
  Running[44]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Nativeint.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Nativeint.deps
  Running[45]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Obj.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Obj.deps
  Running[46]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Oo.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Oo.deps
  Running[47]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Option.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Option.deps
  Running[48]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Out_channel.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Out_channel.deps
  Running[49]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Parsing.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Parsing.deps
  Running[50]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Printexc.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Printexc.deps
  Running[51]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Printf.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Printf.deps
  Running[52]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Queue.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Queue.deps
  Running[53]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Random.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Random.deps
  Running[54]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Result.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Result.deps
  Running[55]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Scanf.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Scanf.deps
  Running[56]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Semaphore.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Semaphore.deps
  Running[57]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Seq.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Seq.deps
  Running[58]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Set.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Set.deps
  Running[59]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Stack.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Stack.deps
  Running[60]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__StdLabels.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__StdLabels.deps
  Running[61]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__String.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__String.deps
  Running[62]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__StringLabels.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__StringLabels.deps
  Running[63]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Sys.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Sys.deps
  Running[64]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Type.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Type.deps
  Running[65]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Uchar.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Uchar.deps
  Running[66]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Unit.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Unit.deps
  Running[67]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Weak.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Weak.deps
  Running[68]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-stdlib.odoc stdlib.mld --output-dir .. --parent-id docs)
  Running[69]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/ocamlc.opt -w @1..3@5..28@30..39@43@46..47@49..57@61..62-40 -strict-sequence -strict-formats -short-paths -keep-locs -g -bin-annot -I .odoctest.objs/byte -no-alias-deps -opaque -o .odoctest.objs/byte/odoctest.cmo -c -impl odoctest.ml)
  Running[70]: (cd _build/default/_doc_new/odoc/local/odoctest && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-odoctest.odoc odoctest.mld --output-dir ../.. --parent-id local/local)
  Running[71]: (cd _build/default/_doc_new/odoc/local && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-local.odoc local.mld --output-dir .. --parent-id docs)
  Running[72]: (cd _build/default/_doc_new/odoc && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-docs.odoc docs.mld --output-dir . --parent-id '')
  Running[73]: (cd _build/default/_doc_new/html/docs && /home/panglesd/code/dune/_build/default/test/blackbox-tests/test-cases/.bin/sherlodoc js sherlodoc.js)
  Running[74]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/odoc support-files -o _doc_new/html/docs/odoc.support)
  Running[75]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalFormatBasics.cmti --output-dir .. --parent-id stdlib/stdlib --print-warnings=false)
  Running[76]: (cd _build/default/_doc_new/odoc/local/odoctest && /home/panglesd/code/dune/_opam/bin/odoc compile-deps ../../../../.odoctest.objs/byte/odoctest.cmt) > _build/default/_doc_new/odoc/local/odoctest/odoctest.deps
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/odoctest/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/odoctest/page-odoctest.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/camlinternalFormatBasics.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/page-stdlib.odoc
  [1]

  $ tree _build/default/_doc_new
  _build/default/_doc_new
  |-- html
  |   `-- docs
  |       |-- odoc.support
  |       |   |-- fonts
  |       |   |   |-- KaTeX_AMS-Regular.woff2
  |       |   |   |-- KaTeX_Caligraphic-Bold.woff2
  |       |   |   |-- KaTeX_Caligraphic-Regular.woff2
  |       |   |   |-- KaTeX_Fraktur-Bold.woff2
  |       |   |   |-- KaTeX_Fraktur-Regular.woff2
  |       |   |   |-- KaTeX_Main-Bold.woff2
  |       |   |   |-- KaTeX_Main-BoldItalic.woff2
  |       |   |   |-- KaTeX_Main-Italic.woff2
  |       |   |   |-- KaTeX_Main-Regular.woff2
  |       |   |   |-- KaTeX_Math-BoldItalic.woff2
  |       |   |   |-- KaTeX_Math-Italic.woff2
  |       |   |   |-- KaTeX_SansSerif-Bold.woff2
  |       |   |   |-- KaTeX_SansSerif-Italic.woff2
  |       |   |   |-- KaTeX_SansSerif-Regular.woff2
  |       |   |   |-- KaTeX_Script-Regular.woff2
  |       |   |   |-- KaTeX_Size1-Regular.woff2
  |       |   |   |-- KaTeX_Size2-Regular.woff2
  |       |   |   |-- KaTeX_Size3-Regular.woff2
  |       |   |   |-- KaTeX_Size4-Regular.woff2
  |       |   |   |-- KaTeX_Typewriter-Regular.woff2
  |       |   |   |-- fira-mono-v14-latin-500.woff2
  |       |   |   |-- fira-mono-v14-latin-regular.woff2
  |       |   |   |-- fira-sans-v17-latin-500.woff2
  |       |   |   |-- fira-sans-v17-latin-500italic.woff2
  |       |   |   |-- fira-sans-v17-latin-700.woff2
  |       |   |   |-- fira-sans-v17-latin-700italic.woff2
  |       |   |   |-- fira-sans-v17-latin-italic.woff2
  |       |   |   |-- fira-sans-v17-latin-regular.woff2
  |       |   |   |-- noticia-text-v15-latin-700.woff2
  |       |   |   |-- noticia-text-v15-latin-italic.woff2
  |       |   |   `-- noticia-text-v15-latin-regular.woff2
  |       |   |-- highlight.pack.js
  |       |   |-- katex.min.css
  |       |   |-- katex.min.js
  |       |   |-- odoc.css
  |       |   `-- odoc_search.js
  |       `-- sherlodoc.js
  `-- odoc
      |-- docs
      |   |-- page-local.odoc
      |   `-- page-stdlib.odoc
      |-- docs.mld
      |-- local
      |   |-- local
      |   |   `-- page-odoctest.odoc
      |   |-- local.mld
      |   `-- odoctest
      |       |-- odoctest.deps
      |       `-- odoctest.mld
      |-- page-docs.odoc
      `-- stdlib
          |-- camlinternalFormat.deps
          |-- camlinternalFormatBasics.deps
          |-- camlinternalLazy.deps
          |-- camlinternalMod.deps
          |-- camlinternalOO.deps
          |-- std_exit.deps
          |-- stdlib
          |   `-- camlinternalFormatBasics.odoc
          |-- stdlib.deps
          |-- stdlib.mld
          |-- stdlib__Arg.deps
          |-- stdlib__Array.deps
          |-- stdlib__ArrayLabels.deps
          |-- stdlib__Atomic.deps
          |-- stdlib__Bigarray.deps
          |-- stdlib__Bool.deps
          |-- stdlib__Buffer.deps
          |-- stdlib__Bytes.deps
          |-- stdlib__BytesLabels.deps
          |-- stdlib__Callback.deps
          |-- stdlib__Char.deps
          |-- stdlib__Complex.deps
          |-- stdlib__Condition.deps
          |-- stdlib__Digest.deps
          |-- stdlib__Domain.deps
          |-- stdlib__Effect.deps
          |-- stdlib__Either.deps
          |-- stdlib__Ephemeron.deps
          |-- stdlib__Filename.deps
          |-- stdlib__Float.deps
          |-- stdlib__Format.deps
          |-- stdlib__Fun.deps
          |-- stdlib__Gc.deps
          |-- stdlib__Hashtbl.deps
          |-- stdlib__In_channel.deps
          |-- stdlib__Int.deps
          |-- stdlib__Int32.deps
          |-- stdlib__Int64.deps
          |-- stdlib__Lazy.deps
          |-- stdlib__Lexing.deps
          |-- stdlib__List.deps
          |-- stdlib__ListLabels.deps
          |-- stdlib__Map.deps
          |-- stdlib__Marshal.deps
          |-- stdlib__MoreLabels.deps
          |-- stdlib__Mutex.deps
          |-- stdlib__Nativeint.deps
          |-- stdlib__Obj.deps
          |-- stdlib__Oo.deps
          |-- stdlib__Option.deps
          |-- stdlib__Out_channel.deps
          |-- stdlib__Parsing.deps
          |-- stdlib__Printexc.deps
          |-- stdlib__Printf.deps
          |-- stdlib__Queue.deps
          |-- stdlib__Random.deps
          |-- stdlib__Result.deps
          |-- stdlib__Scanf.deps
          |-- stdlib__Semaphore.deps
          |-- stdlib__Seq.deps
          |-- stdlib__Set.deps
          |-- stdlib__Stack.deps
          |-- stdlib__StdLabels.deps
          |-- stdlib__String.deps
          |-- stdlib__StringLabels.deps
          |-- stdlib__Sys.deps
          |-- stdlib__Type.deps
          |-- stdlib__Uchar.deps
          |-- stdlib__Unit.deps
          `-- stdlib__Weak.deps
  
  12 directories, 114 files











  $ grep unresolved _build/default/_doc_new/html/docs/local/odoctest/Odoctest/index.html
  grep: _build/default/_doc_new/html/docs/local/odoctest/Odoctest/index.html: No such file or directory
  [2]
