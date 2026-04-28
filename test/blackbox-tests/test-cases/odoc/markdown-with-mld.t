Test markdown generation with package documentation (.mld files)

  $ cat > dune-project << EOF
  > (lang dune 3.10)
  > (package
  >  (name example))
  > EOF

  $ cat > dune << EOF
  > (library
  >  (public_name example))
  > EOF

  $ cat > example.ml << EOF
  > (** Example library module *)
  > 
  > let greet name = Printf.sprintf "Hello, %s!" name
  > EOF

  $ cat > index.mld << EOF
  > {0 Example Package}
  > 
  > This is the documentation for the example package.
  > 
  > {1 Overview}
  > 
  > This package provides a simple greeting function.
  > 
  > {2 Usage}
  > 
  > {[
  > let message = Example.greet "World"
  > ]}
  > 
  > See {!Example} for the API documentation.
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
  File "_index/index.mld", line 3, characters 2-33:
  Warning: Failed to resolve reference /example/index Path '/example/index' not found
  File "_mlds/example/index.mld", line 4, characters 0-26:
  Warning: Failed to resolve reference /example/Example Path '/example/Example' not found

  $ find _build/default/_doc/_markdown -name '*.md' | sort
  _build/default/_doc/_markdown/example/example/Example.md
  _build/default/_doc/_markdown/example/example/index.md
  _build/default/_doc/_markdown/example/index.md
  _build/default/_doc/_markdown/index.md

  $ ls _build/default/_doc/_markdown/example/
  example
  index.md

  $ dune build @doc-markdown

  $ dune build @doc @doc-markdown
  $ find _build/default/_doc -name 'index.*' | grep -E '(html|md)$' | sort
  _build/default/_doc/_html/example/example/Example/index.html
  _build/default/_doc/_html/example/example/index.html
  _build/default/_doc/_html/example/index.html
  _build/default/_doc/_html/index.html
  _build/default/_doc/_markdown/example/example/index.md
  _build/default/_doc/_markdown/example/index.md
  _build/default/_doc/_markdown/index.md
