Using same melange.emit target in two contexts, where the stanzas are defined
in the same dune file

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
  $ cat > dune << EOF
  > (melange.emit
  >  (target foo)
  >  (enabled_if (= %{context_name} "default")))
  > (melange.emit
  >  (target foo)
  >  (enabled_if (= %{context_name} "alt-context")))
  > EOF
  $ cat > foo.ml <<EOF
  > let () = print_endline "foo"
  > EOF

  $ dune build
  File "dune", lines 1-3, characters 0-72:
  1 | (melange.emit
  2 |  (target foo)
  3 |  (enabled_if (= %{context_name} "default")))
  Error: Library "melange" not found.
  -> required by _build/default/foo/foo.js
  -> required by alias all
  -> required by alias default
  File "dune", lines 4-6, characters 0-76:
  4 | (melange.emit
  5 |  (target foo)
  6 |  (enabled_if (= %{context_name} "alt-context")))
  Error: Library "melange" not found.
  -> required by _build/alt-context/foo/foo.js
  -> required by alias all (context alt-context)
  -> required by alias default (context alt-context)
  [1]
