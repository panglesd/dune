Using same melange.emit target in two contexts

  $ mkdir -p a b
  $ cat > dune-project << EOF
  > (lang dune 3.13)
  > (using melange 0.1)
  > EOF

  $ cat > dune-workspace << EOF
  > (lang dune 3.13)
  > 
  > (context default)
  > 
  > (context
  >  (default
  >   (name alt-context)))
  > EOF
  $ cat > a/dune << EOF
  > (melange.emit
  >  (target foo)
  >  (enabled_if (= %{context_name} "default")))
  > EOF
  $ cat > a/foo.ml <<EOF
  > let () = print_endline "foo"
  > EOF

  $ cat > b/dune << EOF
  > (melange.emit
  >  (target foo)
  >  (enabled_if (= %{context_name} "alt-context")))
  > EOF
  $ cat > b/foo.ml <<EOF
  > let () = print_endline "foo"
  > EOF

  $ dune build
  File "a/dune", lines 1-3, characters 0-72:
  1 | (melange.emit
  2 |  (target foo)
  3 |  (enabled_if (= %{context_name} "default")))
  Error: Library "melange" not found.
  -> required by _build/default/a/foo/a/foo.js
  -> required by alias a/all
  -> required by alias default
  File "b/dune", lines 1-3, characters 0-76:
  1 | (melange.emit
  2 |  (target foo)
  3 |  (enabled_if (= %{context_name} "alt-context")))
  Error: Library "melange" not found.
  -> required by _build/alt-context/b/foo/b/foo.js
  -> required by alias b/all (context alt-context)
  -> required by alias default (context alt-context)
  [1]
