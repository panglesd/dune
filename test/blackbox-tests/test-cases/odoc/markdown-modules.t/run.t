Test that markdown generation includes all modules following naming conventions.

  $ cat > dune-project << EOF
  > (lang dune 3.0)
  > (package (name mylib))
  > EOF

  $ cat > dune << EOF
  > (library
  >  (public_name mylib))
  > EOF

  $ dune build @doc-markdown
  Error: No rule found for alias _doc/_markdown/mylib/doc-markdown
  -> required by alias doc-markdown
  [1]

  $ find _build/default/_doc/_markdown -name "*.md" | sort
  find: '_build/default/_doc/_markdown': No such file or directory
  [1]

  $ cat _build/default/_doc/_markdown/mylib/Mylib.md
  cat: _build/default/_doc/_markdown/mylib/Mylib.md: No such file or directory
  [1]
