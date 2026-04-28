This test generates documentation for non-hidden modules only for a library:

  $ dune build @doc
  File "_index/index.mld", line 3, characters 2-25:
  Warning: Failed to resolve reference /foo/index Path '/foo/index' not found
  File "domain.mli", line 69, character 4 to line 74, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "fun.mli", line 92, characters 3-8:
  Warning: 'const' is deprecated, use 'constructor' instead.
  File "scanf.mli", line 86, character 0 to line 88, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "array.mli", line 449, character 1 to line 455, character 2:
  Warning: Code blocks should be indented at the opening `{`.
  File "arrayLabels.mli", line 449, character 1 to line 455, character 2:
  Warning: Code blocks should be indented at the opening `{`.
  File "buffer.mli", line 35, character 0 to line 37, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "bytes.mli", line 368, character 3 to line 373, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytes.mli", line 395, character 3 to line 398, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytes.mli", line 432, character 4 to line 435, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytesLabels.mli", line 368, character 3 to line 373, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytesLabels.mli", line 395, character 3 to line 398, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "bytesLabels.mli", line 432, character 4 to line 435, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "dynarray.mli", line 47, character 0 to line 49, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "hashtbl.mli", line 47, character 0 to line 49, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "queue.mli", line 24, character 0 to line 26, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "stack.mli", line 23, character 0 to line 25, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "format.mli", line 363, character 3 to line 369, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "format.mli", line 372, character 3 to line 375, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "format.mli", line 1575, character 2 to line 1579, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "ephemeron.mli", line 70, character 0 to line 72, character 1:
  Warning: Alert unsynchronized_access not expected here.
  File "moreLabels.mli", line 64, character 2 to line 66, character 3:
  Warning: Alert unsynchronized_access not expected here.
  File "gc.mli", line 431, character 3 to line 440, character 5:
  Warning: Code blocks should be indented at the opening `{`.
  File "_mlds/foo/index.mld", line 4, characters 0-18:
  Warning: Failed to resolve reference /foo/Foo Path '/foo/Foo' not found

 Hidden modules should be compiled
  $ find _build/default -name '*.odoc' | sort -n
  _build/default/_doc/_index/page-index.odoc
  _build/default/_doc/_odoc/foo/foo/foo.odoc
  _build/default/_doc/_odoc/foo/foo/foo__.odoc
  _build/default/_doc/_odoc/foo/foo/foo__Bar.odoc
  _build/default/_doc/_odoc/foo/foo/page-index.odoc
  _build/default/_doc/_odoc/foo/page-index.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/camlinternalFormat.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/camlinternalFormatBasics.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/camlinternalLazy.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/camlinternalMod.odoc
  _build/default/_doc/_odoc/stdlib/stdlib/camlinternalOO.odoc
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
  _build/default/_doc/_odocls/foo/foo/page-index.odocl
  _build/default/_doc/_odocls/foo/page-index.odocl

 We don't expect html for hidden modules
  $ find _build/default -name '*.html' | sort -n
  _build/default/_doc/_html/foo/foo/Foo/index.html
  _build/default/_doc/_html/foo/foo/index.html
  _build/default/_doc/_html/foo/index.html
  _build/default/_doc/_html/index.html
