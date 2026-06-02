This test generates documentation for non-hidden modules only for a library:

  $ dune build @doc

 Hidden modules should be compiled
  $ find _build/default -name '*.odoc' | sort -n
  _build/default/_doc/_index/page-index.odoc
  _build/default/_doc/_odoc/foo/foo/foo.odoc
  _build/default/_doc/_odoc/foo/foo/foo__.odoc
  _build/default/_doc/_odoc/foo/foo/foo__Bar.odoc
  _build/default/_doc/_odoc/foo/foo/impl-foo.odoc
  _build/default/_doc/_odoc/foo/foo/impl-foo__.odoc
  _build/default/_doc/_odoc/foo/foo/impl-foo__Bar.odoc
  _build/default/_doc/_odoc/foo/foo/page-index.odoc
  _build/default/_doc/_odoc/foo/page-index.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/camlinternalFormat.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/camlinternalFormatBasics.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/camlinternalLazy.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/camlinternalMod.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/camlinternalOO.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/impl-camlinternalFormat.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/impl-camlinternalFormatBasics.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/impl-camlinternalLazy.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/impl-camlinternalMod.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/impl-camlinternalOO.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/impl-stdlib.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Arg.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Array.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__ArrayLabels.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Atomic.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Bigarray.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Bool.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Buffer.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Bytes.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__BytesLabels.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Callback.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Char.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Complex.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Condition.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Digest.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Domain.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Dynarray.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Effect.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Either.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Ephemeron.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Filename.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Float.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Format.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Fun.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Gc.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Hashtbl.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Iarray.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__In_channel.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Int.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Int32.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Int64.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Lazy.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Lexing.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__List.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__ListLabels.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Map.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Marshal.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__MoreLabels.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Mutex.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Nativeint.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Obj.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Oo.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Option.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Out_channel.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Pair.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Parsing.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Pqueue.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Printexc.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Printf.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Queue.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Random.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Repr.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Result.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Scanf.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Semaphore.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Seq.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Set.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Stack.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__StdLabels.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__String.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__StringLabels.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Sys.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Type.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Uchar.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Unit.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/stdlib__Weak.odoc

 Hidden modules should not be linked
  $ find _build/default -name '*.odocl' | sort -n
  _build/default/_doc/_index/page-index.odocl
  _build/default/_doc/_odocls/foo/foo/foo.odocl
  _build/default/_doc/_odocls/foo/foo/impl-foo.odocl
  _build/default/_doc/_odocls/foo/foo/impl-foo__.odocl
  _build/default/_doc/_odocls/foo/foo/impl-foo__Bar.odocl
  _build/default/_doc/_odocls/foo/foo/page-index.odocl
  _build/default/_doc/_odocls/foo/page-index.odocl

 We don't expect html for hidden modules
  $ find _build/default -name '*.html' | sort -n
  _build/default/_doc/_html/foo/foo/Foo/index.html
  _build/default/_doc/_html/foo/foo/index.html
  _build/default/_doc/_html/foo/index.html
  _build/default/_doc/_html/foo/src/foo/bar.ml.html
  _build/default/_doc/_html/foo/src/foo/foo.ml.html
  _build/default/_doc/_html/foo/src/foo/foo__.ml-gen.html
  _build/default/_doc/_html/index.html
