This test generates documentation for non-hidden modules only for a library:

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
  Running[69]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/ocamldep.opt -modules -impl foo.ml) > _build/default/.foo.objs/foo.impl.d
  Running[70]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/ocamlc.opt -w @1..3@5..28@30..39@43@46..47@49..57@61..62-40 -strict-sequence -strict-formats -short-paths -keep-locs -w -49 -nopervasives -nostdlib -g -bin-annot -I .foo.objs/byte -no-alias-deps -opaque -o .foo.objs/byte/foo__.cmo -c -impl foo__.ml-gen)
  Running[71]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/ocamldep.opt -modules -impl bar.ml) > _build/default/.foo.objs/foo__Bar.impl.d
  Running[72]: (cd _build/default/_doc_new/odoc/local/foo && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-foo.odoc foo.mld --output-dir ../.. --parent-id local/local)
  Running[73]: (cd _build/default/_doc_new/odoc/local && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-local.odoc local.mld --output-dir .. --parent-id docs)
  Running[74]: (cd _build/default/_doc_new/odoc && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-docs.odoc docs.mld --output-dir . --parent-id '')
  Running[75]: (cd _build/default/_doc_new/html/docs && /home/panglesd/code/dune/_build/default/test/blackbox-tests/test-cases/.bin/sherlodoc js sherlodoc.js)
  Running[76]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/odoc support-files -o _doc_new/html/docs/odoc.support)
  Running[77]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalFormatBasics.cmti --output-dir .. --parent-id stdlib/stdlib --print-warnings=false)
  Running[78]: (cd _build/default/_doc_new/odoc/local/foo && /home/panglesd/code/dune/_opam/bin/odoc compile-deps ../../../../.foo.objs/byte/foo__.cmt) > _build/default/_doc_new/odoc/local/foo/foo__.deps
  Running[79]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/ocamlc.opt -w @1..3@5..28@30..39@43@46..47@49..57@61..62-40 -strict-sequence -strict-formats -short-paths -keep-locs -g -bin-annot -I .foo.objs/byte -no-alias-deps -opaque -open Foo__ -o .foo.objs/byte/foo.cmo -c -impl foo.ml)
  Running[80]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/ocamlc.opt -w @1..3@5..28@30..39@43@46..47@49..57@61..62-40 -strict-sequence -strict-formats -short-paths -keep-locs -g -bin-annot -I .foo.objs/byte -no-alias-deps -opaque -open Foo__ -o .foo.objs/byte/foo__Bar.cmo -c -impl bar.ml)
  Running[81]: (cd _build/default/_doc_new/odoc/local/foo && /home/panglesd/code/dune/_opam/bin/odoc compile-deps ../../../../.foo.objs/byte/foo.cmt) > _build/default/_doc_new/odoc/local/foo/foo.deps
  Running[82]: (cd _build/default/_doc_new/odoc/local/foo && /home/panglesd/code/dune/_opam/bin/odoc compile-deps ../../../../.foo.objs/byte/foo__Bar.cmt) > _build/default/_doc_new/odoc/local/foo/foo__Bar.deps
  File "_doc_new/odoc/local/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/page-local.odoc
  File "_doc_new/odoc/local/foo/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/local/foo/page-foo.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/camlinternalFormatBasics.odoc
  File "_doc_new/odoc/stdlib/_unknown_", line 1, characters 0-0:
  Error: Rule failed to generate the following targets:
  - _doc_new/odoc/stdlib/page-stdlib.odoc
  [1]

 Hidden modules should be compiled
  $ find _build/default/_doc_new/odoc/local/foo -name '*.odoc' | sort -n

 Hidden modules should not be linked
  $ find _build/default/_doc_new/odoc/local/foo -name '*.odocl' | sort -n

 We don't expect html for hidden modules
  $ find _build/default/_doc_new/html/docs/local/foo -name '*.html' | sort -n
  find: '_build/default/_doc_new/html/docs/local/foo': No such file or directory
