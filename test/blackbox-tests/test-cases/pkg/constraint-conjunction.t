Exercise the solver on a package with a conjunction in its dependency
constraints.

  $ . ./helpers.sh
  $ mkrepo

  $ mkpkg a

  $ mkpkg foo << EOF
  > depends: [
  >   "a" { >= "0.0.0" & < "1.0.0" }
  > ]
  > EOF

  $ solve foo
  Solution for dune.lock:
  - a.0.0.1
  - foo.0.0.1

Note that this is currently incorrect as the package "a" is duplicated
in the "depends" field.
  $ cat dune.lock/foo.pkg
  (version 0.0.1)
  
  (depends a a)
