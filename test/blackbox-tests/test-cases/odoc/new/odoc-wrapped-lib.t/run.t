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
  Running[68]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-stdlib.odoc stdlib.mld --output-dir .. --parent-id stdlib)
  Running[69]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/ocamldep.opt -modules -impl foo.ml) > _build/default/.foo.objs/foo.impl.d
  Running[70]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/ocamlc.opt -w @1..3@5..28@30..39@43@46..47@49..57@61..62-40 -strict-sequence -strict-formats -short-paths -keep-locs -w -49 -nopervasives -nostdlib -g -bin-annot -I .foo.objs/byte -no-alias-deps -opaque -o .foo.objs/byte/foo__.cmo -c -impl foo__.ml-gen)
  Running[71]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/ocamldep.opt -modules -impl bar.ml) > _build/default/.foo.objs/foo__Bar.impl.d
  Running[72]: (cd _build/default/_doc_new/odoc/local/foo && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-foo.odoc foo.mld --output-dir ../.. --parent-id local/foo)
  Running[73]: (cd _build/default/_doc_new/odoc/local && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-local.odoc local.mld --output-dir .. --parent-id local)
  Running[74]: (cd _build/default/_doc_new/odoc && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-docs.odoc docs.mld --output-dir . --parent-id '')
  Running[75]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_build/default/test/blackbox-tests/test-cases/.bin/sherlodoc js sherlodoc.js)
  Running[76]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/odoc support-files -o _doc_new/html/docs/odoc.support)
  Running[77]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalFormatBasics.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[78]: (cd _build/default/_doc_new/odoc/local/foo && /home/panglesd/code/dune/_opam/bin/odoc compile-deps ../../../../.foo.objs/byte/foo__.cmt) > _build/default/_doc_new/odoc/local/foo/foo__.deps
  Running[79]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/ocamlc.opt -w @1..3@5..28@30..39@43@46..47@49..57@61..62-40 -strict-sequence -strict-formats -short-paths -keep-locs -g -bin-annot -I .foo.objs/byte -no-alias-deps -opaque -open Foo__ -o .foo.objs/byte/foo.cmo -c -impl foo.ml)
  Running[80]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/ocamlc.opt -w @1..3@5..28@30..39@43@46..47@49..57@61..62-40 -strict-sequence -strict-formats -short-paths -keep-locs -g -bin-annot -I .foo.objs/byte -no-alias-deps -opaque -open Foo__ -o .foo.objs/byte/foo__Bar.cmo -c -impl bar.ml)
  Running[81]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[82]: (cd _build/default/_doc_new/odoc/local/foo && /home/panglesd/code/dune/_opam/bin/odoc compile-deps ../../../../.foo.objs/byte/foo.cmt) > _build/default/_doc_new/odoc/local/foo/foo.deps
  Running[83]: (cd _build/default/_doc_new/odoc/local/foo && /home/panglesd/code/dune/_opam/bin/odoc compile-deps ../../../../.foo.objs/byte/foo__Bar.cmt) > _build/default/_doc_new/odoc/local/foo/foo__Bar.deps
  Running[84]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalLazy.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[85]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/std_exit.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[86]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Arg.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[87]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Atomic.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[88]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Bool.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[89]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Callback.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[90]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Char.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[91]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Complex.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[92]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Digest.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[93]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Domain.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[94]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Either.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[95]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Filename.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[96]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Fun.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[97]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__In_channel.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[98]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Int.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[99]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Int32.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[100]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Int64.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[101]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Lexing.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[102]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Marshal.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[103]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Mutex.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[104]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Nativeint.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[105]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Out_channel.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[106]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Scanf.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[107]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Semaphore.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[108]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__StdLabels.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[109]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Sys.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[110]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Type.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[111]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Uchar.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[112]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Unit.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[113]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Lazy.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[114]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Bigarray.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[115]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Seq.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[116]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Obj.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[117]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Condition.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[118]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Random.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[119]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Array.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[120]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__ArrayLabels.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[121]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Buffer.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[122]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Bytes.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[123]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__BytesLabels.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[124]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Float.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[125]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Hashtbl.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[126]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__List.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[127]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__ListLabels.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[128]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Map.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[129]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Option.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[130]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Queue.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[131]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Result.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[132]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Set.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[133]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Stack.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[134]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__String.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[135]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__StringLabels.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[136]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalMod.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[137]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalOO.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[138]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Parsing.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[139]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Printexc.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[140]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalFormat.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[141]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Format.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[142]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Printf.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[143]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Ephemeron.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[144]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Weak.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[145]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__MoreLabels.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[146]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Oo.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[147]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Effect.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[148]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Gc.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[149]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o camlinternalFormat.odocl camlinternalFormat.odoc --print-warnings=false)
  Running[150]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o camlinternalFormatBasics.odocl camlinternalFormatBasics.odoc --print-warnings=false)
  Running[151]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o camlinternalLazy.odocl camlinternalLazy.odoc --print-warnings=false)
  Running[152]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o camlinternalMod.odocl camlinternalMod.odoc --print-warnings=false)
  Running[153]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o camlinternalOO.odocl camlinternalOO.odoc --print-warnings=false)
  Running[154]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o page-stdlib.odocl page-stdlib.odoc)
  Running[155]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o std_exit.odocl std_exit.odoc --print-warnings=false)
  Running[156]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o stdlib.odocl stdlib.odoc --print-warnings=false)
  Running[157]: (cd _build/default/_doc_new/odoc/local/foo && /home/panglesd/code/dune/_opam/bin/odoc compile -I . -I ../../stdlib ../../../../.foo.objs/byte/foo__.cmt --output-dir ../.. --parent-id local/foo)
  Running[158]: (cd _build/default/_doc_new/odoc/local && /home/panglesd/code/dune/_opam/bin/odoc link -I foo -I ../stdlib -o page-local.odocl page-local.odoc)
  Running[159]: (cd _build/default/_doc_new/odoc && /home/panglesd/code/dune/_opam/bin/odoc link -I local -I local/foo -I stdlib -o page-docs.odocl page-docs.odoc)
  Running[160]: (cd _build/default/_doc_new/odoc/local/foo && /home/panglesd/code/dune/_opam/bin/odoc compile -I . -I ../../stdlib ../../../../.foo.objs/byte/foo.cmt --output-dir ../.. --parent-id local/foo)
  Running[161]: (cd _build/default/_doc_new/odoc/local/foo && /home/panglesd/code/dune/_opam/bin/odoc compile -I . -I ../../stdlib ../../../../.foo.objs/byte/foo__Bar.cmt --output-dir ../.. --parent-id local/foo)
  Running[162]: (cd _build/default/_doc_new/odoc/local/foo && /home/panglesd/code/dune/_opam/bin/odoc link -I . -I ../../stdlib -o page-foo.odocl page-foo.odoc)
  Running[163]: (cd _build/default/_doc_new/odoc/local/foo && /home/panglesd/code/dune/_opam/bin/odoc link -I . -I ../../stdlib -o foo.odocl foo.odoc)
  Running[164]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_build/default/test/blackbox-tests/test-cases/.bin/sherlodoc index ../odoc/stdlib/page-stdlib.odocl ../odoc/stdlib/stdlib.odocl ../odoc/stdlib/std_exit.odocl ../odoc/stdlib/camlinternalOO.odocl ../odoc/stdlib/camlinternalMod.odocl ../odoc/stdlib/camlinternalLazy.odocl ../odoc/stdlib/camlinternalFormatBasics.odocl ../odoc/stdlib/camlinternalFormat.odocl --favoured ../odoc/local/foo/page-foo.odocl --favoured ../odoc/local/foo/foo.odocl --favoured ../odoc/local/page-local.odocl --favoured ../odoc/page-docs.odocl --favoured-prefixes '""' --format=js --db db.js)
  Running[165]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/page-docs.odocl)
  Running[166]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/local/page-local.odocl)
  Running[167]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/local/foo/foo.odocl)
  Running[168]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/local/foo/page-foo.odocl)
  Running[169]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/stdlib/camlinternalFormat.odocl)
  Running[170]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/stdlib/camlinternalFormatBasics.odocl)
  Running[171]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/stdlib/camlinternalLazy.odocl)
  Running[172]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/stdlib/camlinternalMod.odocl)
  Running[173]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/stdlib/camlinternalOO.odocl)
  Running[174]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/stdlib/std_exit.odocl)
  Running[175]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/stdlib/stdlib.odocl)
  Running[176]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_opam/bin/odoc html-generate -o . --search-uri db.js --search-uri sherlodoc.js --support-uri docs/odoc.support --theme-uri docs/odoc.support ../odoc/stdlib/page-stdlib.odocl)

 Hidden modules should be compiled
  $ find _build/default/_doc_new/odoc/local/foo -name '*.odoc' | sort -n
  _build/default/_doc_new/odoc/local/foo/foo.odoc
  _build/default/_doc_new/odoc/local/foo/foo__.odoc
  _build/default/_doc_new/odoc/local/foo/foo__Bar.odoc
  _build/default/_doc_new/odoc/local/foo/page-foo.odoc

 Hidden modules should not be linked
  $ find _build/default/_doc_new/odoc/local/foo -name '*.odocl' | sort -n
  _build/default/_doc_new/odoc/local/foo/foo.odocl
  _build/default/_doc_new/odoc/local/foo/page-foo.odocl

 We don't expect html for hidden modules
  $ find _build/default/_doc_new/html/docs/local/foo -name '*.html' | sort -n
  find: '_build/default/_doc_new/html/docs/local/foo': No such file or directory
