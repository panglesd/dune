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

  $ find _build/default/_doc/_markdown -type d | sort
  find: '_build/default/_doc/_markdown': No such file or directory
  [1]

  $ find _build/default/_doc/_markdown -name "*.md" | sort
  find: '_build/default/_doc/_markdown': No such file or directory
  [1]

  $ cat _build/default/_doc/_markdown/index.md
  cat: _build/default/_doc/_markdown/index.md: No such file or directory
  [1]
