Test markdown with multiple packages and dependencies

  $ cat > dune-project << EOF
  > (lang dune 3.10)
  > (package (name core_lib))
  > (package (name utils_lib))
  > (package (name app_lib))
  > EOF

  $ mkdir -p core
  $ cat > core/dune << EOF
  > (library
  >  (public_name core_lib))
  > EOF

  $ cat > core/core_lib.ml << EOF
  > let version = "1.0.0"
  > EOF

  $ cat > core/core_lib.mli << EOF
  > val version : string
  > EOF

  $ mkdir -p utils
  $ cat > utils/dune << EOF
  > (library
  >  (public_name utils_lib)
  >  (libraries core_lib))
  > EOF

  $ cat > utils/utils_lib.ml << EOF
  > let get_version () = Core_lib.version
  > EOF

  $ cat > utils/utils_lib.mli << EOF
  > val get_version : unit -> string
  > EOF

  $ mkdir -p app
  $ cat > app/dune << EOF
  > (library
  >  (public_name app_lib)
  >  (libraries core_lib utils_lib))
  > EOF

  $ cat > app/app_lib.ml << EOF
  > let run () = Printf.printf "Running version %s\n" (Utils_lib.get_version ())
  > EOF

  $ cat > app/app_lib.mli << EOF
  > val run : unit -> unit
  > EOF

  $ dune build @doc-markdown
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
  File "_index/index.mld", line 5, characters 2-37:
  Warning: Failed to resolve reference /utils_lib/index Path '/utils_lib/index' not found
  File "_index/index.mld", line 4, characters 2-35:
  Warning: Failed to resolve reference /core_lib/index Path '/core_lib/index' not found
  File "_index/index.mld", line 3, characters 2-33:
  Warning: Failed to resolve reference /app_lib/index Path '/app_lib/index' not found

  $ find _build/default/_doc/_markdown -type d | sort
  _build/default/_doc/_markdown
  _build/default/_doc/_markdown/app_lib
  _build/default/_doc/_markdown/app_lib/app_lib
  _build/default/_doc/_markdown/core_lib
  _build/default/_doc/_markdown/core_lib/core_lib
  _build/default/_doc/_markdown/utils_lib
  _build/default/_doc/_markdown/utils_lib/utils_lib

  $ find _build/default/_doc/_markdown -name "*.md" | sort
  _build/default/_doc/_markdown/app_lib/app_lib/App_lib.md
  _build/default/_doc/_markdown/app_lib/app_lib/index.md
  _build/default/_doc/_markdown/app_lib/index.md
  _build/default/_doc/_markdown/core_lib/core_lib/Core_lib.md
  _build/default/_doc/_markdown/core_lib/core_lib/index.md
  _build/default/_doc/_markdown/core_lib/index.md
  _build/default/_doc/_markdown/index.md
  _build/default/_doc/_markdown/utils_lib/index.md
  _build/default/_doc/_markdown/utils_lib/utils_lib/Utils_lib.md
  _build/default/_doc/_markdown/utils_lib/utils_lib/index.md

  $ cat _build/default/_doc/_markdown/index.md
  
  # OCaml package documentation
  
  - `app_lib`
  - `core_lib`
  - `utils_lib`
