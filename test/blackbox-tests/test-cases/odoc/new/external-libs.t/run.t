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
  Running[1]: (cd _build/default && /home/panglesd/code/dune/_opam/bin/odoc support-files -o _doc_new/html/docs/odoc.support)
  Running[2]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalFormat.cmti) > _build/default/_doc_new/odoc/stdlib/camlinternalFormat.deps
  Running[3]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalFormatBasics.cmti) > _build/default/_doc_new/odoc/stdlib/camlinternalFormatBasics.deps
  Running[4]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalLazy.cmti) > _build/default/_doc_new/odoc/stdlib/camlinternalLazy.deps
  Running[5]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalMod.cmti) > _build/default/_doc_new/odoc/stdlib/camlinternalMod.deps
  Running[6]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalOO.cmti) > _build/default/_doc_new/odoc/stdlib/camlinternalOO.deps
  Running[7]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/std_exit.cmti) > _build/default/_doc_new/odoc/stdlib/std_exit.deps
  Running[8]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib.deps
  Running[9]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Arg.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Arg.deps
  Running[10]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Array.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Array.deps
  Running[11]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__ArrayLabels.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__ArrayLabels.deps
  Running[12]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Atomic.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Atomic.deps
  Running[13]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Bigarray.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Bigarray.deps
  Running[14]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Bool.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Bool.deps
  Running[15]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Buffer.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Buffer.deps
  Running[16]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Bytes.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Bytes.deps
  Running[17]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__BytesLabels.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__BytesLabels.deps
  Running[18]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Callback.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Callback.deps
  Running[19]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Char.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Char.deps
  Running[20]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Complex.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Complex.deps
  Running[21]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Condition.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Condition.deps
  Running[22]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Digest.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Digest.deps
  Running[23]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Domain.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Domain.deps
  Running[24]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Effect.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Effect.deps
  Running[25]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Either.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Either.deps
  Running[26]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Ephemeron.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Ephemeron.deps
  Running[27]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Filename.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Filename.deps
  Running[28]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Float.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Float.deps
  Running[29]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Format.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Format.deps
  Running[30]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Fun.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Fun.deps
  Running[31]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Gc.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Gc.deps
  Running[32]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Hashtbl.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Hashtbl.deps
  Running[33]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__In_channel.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__In_channel.deps
  Running[34]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Int.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Int.deps
  Running[35]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Int32.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Int32.deps
  Running[36]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Int64.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Int64.deps
  Running[37]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Lazy.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Lazy.deps
  Running[38]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Lexing.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Lexing.deps
  Running[39]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__List.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__List.deps
  Running[40]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__ListLabels.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__ListLabels.deps
  Running[41]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Map.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Map.deps
  Running[42]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Marshal.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Marshal.deps
  Running[43]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__MoreLabels.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__MoreLabels.deps
  Running[44]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Mutex.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Mutex.deps
  Running[45]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Nativeint.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Nativeint.deps
  Running[46]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Obj.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Obj.deps
  Running[47]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Oo.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Oo.deps
  Running[48]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Option.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Option.deps
  Running[49]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Out_channel.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Out_channel.deps
  Running[50]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Parsing.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Parsing.deps
  Running[51]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Printexc.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Printexc.deps
  Running[52]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Printf.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Printf.deps
  Running[53]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Queue.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Queue.deps
  Running[54]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Random.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Random.deps
  Running[55]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Result.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Result.deps
  Running[56]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Scanf.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Scanf.deps
  Running[57]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Semaphore.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Semaphore.deps
  Running[58]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Seq.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Seq.deps
  Running[59]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Set.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Set.deps
  Running[60]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Stack.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Stack.deps
  Running[61]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__StdLabels.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__StdLabels.deps
  Running[62]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__String.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__String.deps
  Running[63]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__StringLabels.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__StringLabels.deps
  Running[64]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Sys.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Sys.deps
  Running[65]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Type.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Type.deps
  Running[66]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Uchar.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Uchar.deps
  Running[67]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Unit.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Unit.deps
  Running[68]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile-deps /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Weak.cmti) > _build/default/_doc_new/odoc/stdlib/stdlib__Weak.deps
  Running[69]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -o page-stdlib.odoc stdlib.mld --output-dir .. --parent-id stdlib)
  Running[70]: (cd _build/default/_doc_new/html && /home/panglesd/code/dune/_build/default/test/blackbox-tests/test-cases/.bin/sherlodoc js sherlodoc.js)
  Running[71]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalFormatBasics.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[72]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[73]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalLazy.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[74]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/std_exit.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[75]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Arg.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[76]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Atomic.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[77]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Bool.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[78]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Callback.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[79]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Char.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[80]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Complex.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[81]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Digest.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[82]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Domain.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[83]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Either.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[84]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Filename.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[85]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Fun.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[86]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__In_channel.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[87]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Int.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[88]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Int32.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[89]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Int64.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[90]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Lexing.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[91]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Marshal.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[92]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Mutex.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[93]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Nativeint.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[94]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Out_channel.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[95]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Scanf.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[96]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Semaphore.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[97]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__StdLabels.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[98]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Sys.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[99]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Type.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[100]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Uchar.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[101]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Unit.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[102]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Lazy.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[103]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Bigarray.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[104]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Seq.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[105]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Obj.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[106]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Condition.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[107]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Random.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[108]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Array.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[109]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__ArrayLabels.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[110]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Buffer.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[111]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Bytes.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[112]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__BytesLabels.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[113]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Float.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[114]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Hashtbl.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[115]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__List.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[116]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__ListLabels.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[117]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Map.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[118]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Option.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[119]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Queue.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[120]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Result.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[121]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Set.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[122]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Stack.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[123]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__String.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[124]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__StringLabels.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[125]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalMod.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[126]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalOO.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[127]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Parsing.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[128]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Printexc.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[129]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/camlinternalFormat.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[130]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Format.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[131]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Printf.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[132]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Ephemeron.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[133]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Weak.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[134]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__MoreLabels.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[135]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Oo.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[136]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Effect.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[137]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc compile -I . /home/panglesd/code/dune/_opam/lib/ocaml/stdlib__Gc.cmti --output-dir .. --parent-id stdlib --print-warnings=false)
  Running[138]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o camlinternalFormat.odocl camlinternalFormat.odoc --print-warnings=false)
  Running[139]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o camlinternalFormatBasics.odocl camlinternalFormatBasics.odoc --print-warnings=false)
  Running[140]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o camlinternalLazy.odocl camlinternalLazy.odoc --print-warnings=false)
  Running[141]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o camlinternalMod.odocl camlinternalMod.odoc --print-warnings=false)
  Running[142]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o camlinternalOO.odocl camlinternalOO.odoc --print-warnings=false)
  Running[143]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o page-stdlib.odocl page-stdlib.odoc)
  Running[144]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o std_exit.odocl std_exit.odoc --print-warnings=false)
  Running[145]: (cd _build/default/_doc_new/odoc/stdlib && /home/panglesd/code/dune/_opam/bin/odoc link -I . -o stdlib.odocl stdlib.odoc --print-warnings=false)
  Error: Multiple rules generated for
  _build/default/_doc_new/html/local/odoctest/odoctest.html:
  - <internal location>
  - <internal location>
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: Multiple rules generated for
  _build/default/_doc_new/odoc/local/odoctest/odoctest.mld:
  - <internal location>
  - <internal location>
  -> required by _build/default/_doc_new/html/db.js
  -> required by
     _build/default/_doc_new/html/stdlib/CamlinternalFormat/index.html
  -> required by alias _doc_new/html/stdlib/doc-new
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  Error: No rule found for _doc_new/html/docs.html
  -> required by alias _doc_new/html/doc-new
  -> required by alias doc-new
  [1]

  $ tree _build/default/_doc_new
  _build/default/_doc_new
  |-- html
  |   |-- docs
  |   |   `-- odoc.support
  |   |       |-- fonts
  |   |       |   |-- KaTeX_AMS-Regular.woff2
  |   |       |   |-- KaTeX_Caligraphic-Bold.woff2
  |   |       |   |-- KaTeX_Caligraphic-Regular.woff2
  |   |       |   |-- KaTeX_Fraktur-Bold.woff2
  |   |       |   |-- KaTeX_Fraktur-Regular.woff2
  |   |       |   |-- KaTeX_Main-Bold.woff2
  |   |       |   |-- KaTeX_Main-BoldItalic.woff2
  |   |       |   |-- KaTeX_Main-Italic.woff2
  |   |       |   |-- KaTeX_Main-Regular.woff2
  |   |       |   |-- KaTeX_Math-BoldItalic.woff2
  |   |       |   |-- KaTeX_Math-Italic.woff2
  |   |       |   |-- KaTeX_SansSerif-Bold.woff2
  |   |       |   |-- KaTeX_SansSerif-Italic.woff2
  |   |       |   |-- KaTeX_SansSerif-Regular.woff2
  |   |       |   |-- KaTeX_Script-Regular.woff2
  |   |       |   |-- KaTeX_Size1-Regular.woff2
  |   |       |   |-- KaTeX_Size2-Regular.woff2
  |   |       |   |-- KaTeX_Size3-Regular.woff2
  |   |       |   |-- KaTeX_Size4-Regular.woff2
  |   |       |   |-- KaTeX_Typewriter-Regular.woff2
  |   |       |   |-- fira-mono-v14-latin-500.woff2
  |   |       |   |-- fira-mono-v14-latin-regular.woff2
  |   |       |   |-- fira-sans-v17-latin-500.woff2
  |   |       |   |-- fira-sans-v17-latin-500italic.woff2
  |   |       |   |-- fira-sans-v17-latin-700.woff2
  |   |       |   |-- fira-sans-v17-latin-700italic.woff2
  |   |       |   |-- fira-sans-v17-latin-italic.woff2
  |   |       |   |-- fira-sans-v17-latin-regular.woff2
  |   |       |   |-- noticia-text-v15-latin-700.woff2
  |   |       |   |-- noticia-text-v15-latin-italic.woff2
  |   |       |   `-- noticia-text-v15-latin-regular.woff2
  |   |       |-- highlight.pack.js
  |   |       |-- katex.min.css
  |   |       |-- katex.min.js
  |   |       |-- odoc.css
  |   |       `-- odoc_search.js
  |   `-- sherlodoc.js
  `-- odoc
      `-- stdlib
          |-- camlinternalFormat.deps
          |-- camlinternalFormat.odoc
          |-- camlinternalFormat.odocl
          |-- camlinternalFormatBasics.deps
          |-- camlinternalFormatBasics.odoc
          |-- camlinternalFormatBasics.odocl
          |-- camlinternalLazy.deps
          |-- camlinternalLazy.odoc
          |-- camlinternalLazy.odocl
          |-- camlinternalMod.deps
          |-- camlinternalMod.odoc
          |-- camlinternalMod.odocl
          |-- camlinternalOO.deps
          |-- camlinternalOO.odoc
          |-- camlinternalOO.odocl
          |-- page-stdlib.odoc
          |-- page-stdlib.odocl
          |-- std_exit.deps
          |-- std_exit.odoc
          |-- std_exit.odocl
          |-- stdlib.deps
          |-- stdlib.mld
          |-- stdlib.odoc
          |-- stdlib.odocl
          |-- stdlib__Arg.deps
          |-- stdlib__Arg.odoc
          |-- stdlib__Array.deps
          |-- stdlib__Array.odoc
          |-- stdlib__ArrayLabels.deps
          |-- stdlib__ArrayLabels.odoc
          |-- stdlib__Atomic.deps
          |-- stdlib__Atomic.odoc
          |-- stdlib__Bigarray.deps
          |-- stdlib__Bigarray.odoc
          |-- stdlib__Bool.deps
          |-- stdlib__Bool.odoc
          |-- stdlib__Buffer.deps
          |-- stdlib__Buffer.odoc
          |-- stdlib__Bytes.deps
          |-- stdlib__Bytes.odoc
          |-- stdlib__BytesLabels.deps
          |-- stdlib__BytesLabels.odoc
          |-- stdlib__Callback.deps
          |-- stdlib__Callback.odoc
          |-- stdlib__Char.deps
          |-- stdlib__Char.odoc
          |-- stdlib__Complex.deps
          |-- stdlib__Complex.odoc
          |-- stdlib__Condition.deps
          |-- stdlib__Condition.odoc
          |-- stdlib__Digest.deps
          |-- stdlib__Digest.odoc
          |-- stdlib__Domain.deps
          |-- stdlib__Domain.odoc
          |-- stdlib__Effect.deps
          |-- stdlib__Effect.odoc
          |-- stdlib__Either.deps
          |-- stdlib__Either.odoc
          |-- stdlib__Ephemeron.deps
          |-- stdlib__Ephemeron.odoc
          |-- stdlib__Filename.deps
          |-- stdlib__Filename.odoc
          |-- stdlib__Float.deps
          |-- stdlib__Float.odoc
          |-- stdlib__Format.deps
          |-- stdlib__Format.odoc
          |-- stdlib__Fun.deps
          |-- stdlib__Fun.odoc
          |-- stdlib__Gc.deps
          |-- stdlib__Gc.odoc
          |-- stdlib__Hashtbl.deps
          |-- stdlib__Hashtbl.odoc
          |-- stdlib__In_channel.deps
          |-- stdlib__In_channel.odoc
          |-- stdlib__Int.deps
          |-- stdlib__Int.odoc
          |-- stdlib__Int32.deps
          |-- stdlib__Int32.odoc
          |-- stdlib__Int64.deps
          |-- stdlib__Int64.odoc
          |-- stdlib__Lazy.deps
          |-- stdlib__Lazy.odoc
          |-- stdlib__Lexing.deps
          |-- stdlib__Lexing.odoc
          |-- stdlib__List.deps
          |-- stdlib__List.odoc
          |-- stdlib__ListLabels.deps
          |-- stdlib__ListLabels.odoc
          |-- stdlib__Map.deps
          |-- stdlib__Map.odoc
          |-- stdlib__Marshal.deps
          |-- stdlib__Marshal.odoc
          |-- stdlib__MoreLabels.deps
          |-- stdlib__MoreLabels.odoc
          |-- stdlib__Mutex.deps
          |-- stdlib__Mutex.odoc
          |-- stdlib__Nativeint.deps
          |-- stdlib__Nativeint.odoc
          |-- stdlib__Obj.deps
          |-- stdlib__Obj.odoc
          |-- stdlib__Oo.deps
          |-- stdlib__Oo.odoc
          |-- stdlib__Option.deps
          |-- stdlib__Option.odoc
          |-- stdlib__Out_channel.deps
          |-- stdlib__Out_channel.odoc
          |-- stdlib__Parsing.deps
          |-- stdlib__Parsing.odoc
          |-- stdlib__Printexc.deps
          |-- stdlib__Printexc.odoc
          |-- stdlib__Printf.deps
          |-- stdlib__Printf.odoc
          |-- stdlib__Queue.deps
          |-- stdlib__Queue.odoc
          |-- stdlib__Random.deps
          |-- stdlib__Random.odoc
          |-- stdlib__Result.deps
          |-- stdlib__Result.odoc
          |-- stdlib__Scanf.deps
          |-- stdlib__Scanf.odoc
          |-- stdlib__Semaphore.deps
          |-- stdlib__Semaphore.odoc
          |-- stdlib__Seq.deps
          |-- stdlib__Seq.odoc
          |-- stdlib__Set.deps
          |-- stdlib__Set.odoc
          |-- stdlib__Stack.deps
          |-- stdlib__Stack.odoc
          |-- stdlib__StdLabels.deps
          |-- stdlib__StdLabels.odoc
          |-- stdlib__String.deps
          |-- stdlib__String.odoc
          |-- stdlib__StringLabels.deps
          |-- stdlib__StringLabels.odoc
          |-- stdlib__Sys.deps
          |-- stdlib__Sys.odoc
          |-- stdlib__Type.deps
          |-- stdlib__Type.odoc
          |-- stdlib__Uchar.deps
          |-- stdlib__Uchar.odoc
          |-- stdlib__Unit.deps
          |-- stdlib__Unit.odoc
          |-- stdlib__Weak.deps
          `-- stdlib__Weak.odoc
  
  7 directories, 181 files











  $ grep unresolved _build/default/_doc_new/html/docs/local/odoctest/Odoctest/index.html
  grep: _build/default/_doc_new/html/docs/local/odoctest/Odoctest/index.html: No such file or directory
  [2]
