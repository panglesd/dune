Reproduce #8281

Whenever an invalid package name is used, dune crashes when building @doc

  $ make_dune_project 2.4
  $ touch x.opam x.y.opam

  $ mkdir x && cd x
  $ cat >dune <<EOF
  > (library
  >  (public_name x))
  > EOF

  $ mkdir y && cd y
  $ cat >dune <<EOF
  > (library
  >  (public_name x.y)
  >  (name x_y))
  > EOF
  $ cd ..

  $ cd ..

  $ dune build @doc 2>&1 | awk '/Internal error/,/Raised/'
