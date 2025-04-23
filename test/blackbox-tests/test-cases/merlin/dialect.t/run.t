  $ ocamlc_where="$(ocamlc -where)"
  $ export BUILD_PATH_PREFIX_MAP="/OCAMLC_WHERE=$ocamlc_where:$BUILD_PATH_PREFIX_MAP"
  $ ocamlfind_libs="$(ocamlfind printconf path | while read line; do printf lib=${line}:; done)"
  $ export BUILD_PATH_PREFIX_MAP="$ocamlfind_libs:$BUILD_PATH_PREFIX_MAP"
  $ melc_compiler="$(which melc)"
  which: no melc in (/home/panglesd/code/dune/_build/default/test/blackbox-tests/test-cases/.bin:/home/panglesd/code/dune/_build/install/default/bin:/home/panglesd/.opam/5.2.0/bin:/home/panglesd/.local/bin:/home/panglesd/.opam/5.3.0/bin:/home/panglesd/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl)
  [1]
  $ export BUILD_PATH_PREFIX_MAP="/MELC_COMPILER=$melc_compiler:$BUILD_PATH_PREFIX_MAP"

CRAM sanitization
  $ dune build ./exe/.merlin-conf/exe-x --profile release
  $ dune ocaml merlin dump-config $PWD/exe
  X: _build/MELC_COMPILER/default/exe/x
  ((INDEX $TESTCASE_ROOT/_build/default/exe/.x.eobjs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/lib/.x.objs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/melange/.x_mel.objs/cctx.ocaml-index)
   (STDLIB /OCAMLC_WHERE)
   (SOURCE_ROOT $TESTCASE_ROOT)
   (EXCLUDE_QUERY_DIR)
   (B $TESTCASE_ROOT/_build/default/exe/.x.eobjs/byte)
   (S $TESTCASE_ROOT/exe)
   (FLG (-w -40 -g))
   (UNIT_NAME dune__exe__X)
   (SUFFIX ".mlx .mlx"))
  X: _build/MELC_COMPILER/default/exe/x.mlx
  ((INDEX $TESTCASE_ROOT/_build/default/exe/.x.eobjs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/lib/.x.objs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/melange/.x_mel.objs/cctx.ocaml-index)
   (STDLIB /OCAMLC_WHERE)
   (SOURCE_ROOT $TESTCASE_ROOT)
   (EXCLUDE_QUERY_DIR)
   (B $TESTCASE_ROOT/_build/default/exe/.x.eobjs/byte)
   (S $TESTCASE_ROOT/exe)
   (FLG (-w -40 -g))
   (UNIT_NAME dune__exe__X)
   (SUFFIX ".mlx .mlx")
   (READER (mlx)))
  X: _build/MELC_COMPILER/default/exe/x.mlx.mli
  ((INDEX $TESTCASE_ROOT/_build/default/exe/.x.eobjs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/lib/.x.objs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/melange/.x_mel.objs/cctx.ocaml-index)
   (STDLIB /OCAMLC_WHERE)
   (SOURCE_ROOT $TESTCASE_ROOT)
   (EXCLUDE_QUERY_DIR)
   (B $TESTCASE_ROOT/_build/default/exe/.x.eobjs/byte)
   (S $TESTCASE_ROOT/exe)
   (FLG (-w -40 -g))
   (UNIT_NAME dune__exe__X)
   (SUFFIX ".mlx .mlx"))

CRAM sanitization
  $ dune build ./lib/.merlin-conf/lib-x --profile release
  $ dune ocaml merlin dump-config $PWD/lib
  X: _build/MELC_COMPILER/default/lib/x
  ((INDEX $TESTCASE_ROOT/_build/default/exe/.x.eobjs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/lib/.x.objs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/melange/.x_mel.objs/cctx.ocaml-index)
   (STDLIB /OCAMLC_WHERE)
   (SOURCE_ROOT $TESTCASE_ROOT)
   (EXCLUDE_QUERY_DIR)
   (B $TESTCASE_ROOT/_build/default/lib/.x.objs/byte)
   (S $TESTCASE_ROOT/lib)
   (FLG (-w -40 -g))
   (UNIT_NAME x)
   (SUFFIX ".mlx .mlx")
   (READER (mlx)))
  X: _build/MELC_COMPILER/default/lib/x.mlx
  ((INDEX $TESTCASE_ROOT/_build/default/exe/.x.eobjs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/lib/.x.objs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/melange/.x_mel.objs/cctx.ocaml-index)
   (STDLIB /OCAMLC_WHERE)
   (SOURCE_ROOT $TESTCASE_ROOT)
   (EXCLUDE_QUERY_DIR)
   (B $TESTCASE_ROOT/_build/default/lib/.x.objs/byte)
   (S $TESTCASE_ROOT/lib)
   (FLG (-w -40 -g))
   (UNIT_NAME x)
   (SUFFIX ".mlx .mlx")
   (READER (mlx)))

CRAM sanitization
  $ dune build ./melange/.merlin-conf/lib-x_mel --profile release
  $ dune ocaml merlin dump-config $PWD/melange
  X_mel: _build/MELC_COMPILER/default/melange/x_mel
  ((INDEX $TESTCASE_ROOT/_build/default/exe/.x.eobjs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/lib/.x.objs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/melange/.x_mel.objs/cctx.ocaml-index)
   (SOURCE_ROOT $TESTCASE_ROOT)
   (EXCLUDE_QUERY_DIR)
   (B $TESTCASE_ROOT/_build/default/melange/.x_mel.objs/melange)
   (S $TESTCASE_ROOT/melange)
   (FLG (-w -40 -g))
   (UNIT_NAME x_mel)
   (SUFFIX ".mlx .mlx")
   (READER (mlx)))
  X_mel: _build/MELC_COMPILER/default/melange/x_mel.mlx
  ((INDEX $TESTCASE_ROOT/_build/default/exe/.x.eobjs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/lib/.x.objs/cctx.ocaml-index)
   (INDEX $TESTCASE_ROOT/_build/default/melange/.x_mel.objs/cctx.ocaml-index)
   (SOURCE_ROOT $TESTCASE_ROOT)
   (EXCLUDE_QUERY_DIR)
   (B $TESTCASE_ROOT/_build/default/melange/.x_mel.objs/melange)
   (S $TESTCASE_ROOT/melange)
   (FLG (-w -40 -g))
   (UNIT_NAME x_mel)
   (SUFFIX ".mlx .mlx")
   (READER (mlx)))
