Test that references to installed library types are remapped correctly.
This verifies that cross-library references in documentation comments
are resolved to ocaml.org URLs when building with @doc.

Build documentation:

  $ dune build @doc
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
  File "src/astring.mli", line 229, characters 39-62:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 484, characters 41-64:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 993, characters 45-68:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 1000, characters 45-68:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 1007, characters 44-67:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 1014, characters 40-63:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 1051, characters 53-76:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 1058, characters 53-76:
  Warning: '@raise' should begin on its own line.
  File "src/astring.mli", line 1065, characters 48-71:
  Warning: '@raise' should begin on its own line.
  File "utils/config.mli", line 284, characters 24-29:
  Warning: Unknown tag '@FILE'.
  File "utils/config_boot.mli", line 284, characters 24-29:
  Warning: Unknown tag '@FILE'.
  File "utils/config_main.mli", line 284, characters 24-29:
  Warning: Unknown tag '@FILE'.
  File "driver/main_args.mli", line 284, characters 27-34:
  Warning: '{c,opt}': bad markup.
  Suggestion: did you mean '{!c,opt}' or '[c,opt]'?
  File "driver/main_args.mli", line 285, characters 22-29:
  Warning: '{c,opt}': bad markup.
  Suggestion: did you mean '{!c,opt}' or '[c,opt]'?
  File "otherlibs/unix/unix.mli", line 1604, characters 65-78:
  Warning: '@since' should begin on its own line.
  File "src/fpath.mli", line 468, characters 43-66:
  Warning: '@raise' should begin on its own line.
  File "src/fpath.mli", line 475, characters 43-66:
  Warning: '@raise' should begin on its own line.
  File "src/fpath.mli", line 482, characters 42-65:
  Warning: '@raise' should begin on its own line.
  File "src/fpath.mli", line 489, characters 38-61:
  Warning: '@raise' should begin on its own line.
  File "src/fpath.mli", line 519, characters 51-74:
  Warning: '@raise' should begin on its own line.
  File "src/fpath.mli", line 526, characters 51-74:
  Warning: '@raise' should begin on its own line.
  File "src/fpath.mli", line 533, characters 46-69:
  Warning: '@raise' should begin on its own line.
  File "unixLabels.mli", line 1604, characters 65-78:
  Warning: '@since' should begin on its own line.
  File "typing/shape.mli", line 50, characters 0-0:
  Warning: End of text is not allowed in '{{:...} ...}' (external link).
  File "parsing/parsetree.mli", line 674, characters 40-41:
  Warning: '.' is not allowed in '{ul ...}' (bulleted list).
  Suggestion: move '.' into a list item, '{li ...}' or '{- ...}'.
  File "parsing/ast_mapper.mli", line 29, character 2 to line 43, character 35:
  Warning: Code blocks should be indented at the opening `{`.
  File "lib/core.mli", line 79, characters 22-56:
  Warning: Alert deprecated not expected here.
  File "lib/core.mli", line 317, characters 4-29:
  Warning: '6': bad heading level (0-5 allowed).
  File "lib/core.mli", line 370, characters 4-29:
  Warning: '6': bad heading level (0-5 allowed).
  File "lib/core.mli", line 744, characters 26-60:
  Warning: Alert deprecated not expected here.
  File "lib/core.mli", line 767, characters 21-53:
  Warning: Alert deprecated not expected here.
  File "_index/index.mld", line 3, characters 2-33:
  Warning: Failed to resolve reference /testpkg/index Path '/testpkg/index' not found
  File "typing/types.mli", line 16, characters 4-48:
  Warning: '{0': heading level should be lower than top heading level '0'.
  File "typing/types.mli", line 318, character 17 to line 324, character 48:
  Warning: '{ row_fields = [("X", _)];
                     row_more   =
                       Tvariant { row_fields = [("Y", _)];
                                  row_more   =
                                    Tvariant { row_fields = [];
                                               row_more   = _;
                                               _ }': bad markup.
  Suggestion: did you mean '{! row_fields = [("X", _)];
                     row_more   =
                       Tvariant { row_fields = [("Y", _)];
                                  row_more   =
                                    Tvariant { row_fields = [];
                                               row_more   = _;
                                               _ }' or '[ row_fields = [("X", _)];
                     row_more   =
                       Tvariant { row_fields = [("Y", _)];
                                  row_more   =
                                    Tvariant { row_fields = [];
                                               row_more   = _;
                                               _ ]'?
  File "typing/types.mli", line 325, characters 34-35:
  Warning: Unpaired '}' (end of markup).
  Suggestion: try '\}'.
  File "typing/types.mli", line 327, characters 17-18:
  Warning: Unpaired '}' (end of markup).
  Suggestion: try '\}'.
  File "implem/tyxml.ml", line 5, character 4 to line 6, character 100:
  Warning: '{%...%}' (raw markup) needs a target language.
  Suggestion: try '{%html:...%}'.
  File "lib/svg_types.mli", line 2067, characters 0-42:
  Warning: Alert deprecated not expected here.
  File "lib/svg_types.mli", line 2071, characters 0-50:
  Warning: Alert deprecated not expected here.
  File "lib/svg_types.mli", line 2075, characters 0-47:
  Warning: Alert deprecated not expected here.
  File "lib/xml_print.mli", line 40, character 4 to line 42, character 6:
  Warning: Code blocks should be indented at the opening `{`.
  File "typing/out_type.mli", line 125, characters 4-7:
  Warning: Heading label should not be empty.
  File "typing/typedtree.mli", line 59, character 27 to line 60, character 75:
  Warning: '{ pat_desc = P
                             ; pat_extra = (Tpat_constraint T, _, _) :: ... }': bad markup.
  Suggestion: did you mean '{! pat_desc = P
                             ; pat_extra = (Tpat_constraint T, _, _) :: ... }' or '[ pat_desc = P
                             ; pat_extra = (Tpat_constraint T, _, _) :: ... ]'?
  File "typing/typedtree.mli", line 63, character 27 to line 64, character 80:
  Warning: '{ pat_desc = disjunction
                             ; pat_extra = (Tpat_type (P, "tconst"), _, _) :: ...}': bad markup.
  Suggestion: did you mean '{! pat_desc = disjunction
                             ; pat_extra = (Tpat_type (P, "tconst"), _, _) :: ...}' or '[ pat_desc = disjunction
                             ; pat_extra = (Tpat_type (P, "tconst"), _, _) :: ...]'?
  File "typing/typedtree.mli", line 71, character 27 to line 72, character 69:
  Warning: '{ pat_desc  = Tpat_var "P"
                             ; pat_extra = (Tpat_unpack, _, _) :: ... }': bad markup.
  Suggestion: did you mean '{! pat_desc  = Tpat_var "P"
                             ; pat_extra = (Tpat_unpack, _, _) :: ... }' or '[ pat_desc  = Tpat_var "P"
                             ; pat_extra = (Tpat_unpack, _, _) :: ... ]'?
  File "typing/typedtree.mli", line 73, character 27 to line 74, character 54:
  Warning: '{ pat_desc  = Tpat_any
              ; pat_extra = (Tpat_unpack, _, _) :: ... }': bad markup.
  Suggestion: did you mean '{! pat_desc  = Tpat_any
              ; pat_extra = (Tpat_unpack, _, _) :: ... }' or '[ pat_desc  = Tpat_any
              ; pat_extra = (Tpat_unpack, _, _) :: ... ]'?
  File "typing/typedtree.mli", line 124, characters 12-33:
  Warning: '{ l1=P1; ...; ln=Pn }': bad markup.
  Suggestion: did you mean '{! l1=P1; ...; ln=Pn }' or '[ l1=P1; ...; ln=Pn ]'?
  File "typing/typedtree.mli", line 125, characters 12-35:
  Warning: '{ l1=P1; ...; ln=Pn; _}': bad markup.
  Suggestion: did you mean '{! l1=P1; ...; ln=Pn; _}' or '[ l1=P1; ...; ln=Pn; _]'?
  File "typing/typedtree.mli", line 258, characters 12-33:
  Warning: '{ l1=P1; ...; ln=Pn }': bad markup.
  Suggestion: did you mean '{! l1=P1; ...; ln=Pn }' or '[ l1=P1; ...; ln=Pn ]'?
  File "typing/typedtree.mli", line 259, characters 12-41:
  Warning: '{ E0 with l1=P1; ...; ln=Pn }': bad markup.
  Suggestion: did you mean '{! E0 with l1=P1; ...; ln=Pn }' or '[ E0 with l1=P1; ...; ln=Pn ]'?
  File "typing/typedtree.mli", line 263, characters 27-45:
  Warning: '{ l1: t1; l2: t2 }': bad markup.
  Suggestion: did you mean '{! l1: t1; l2: t2 }' or '[ l1: t1; l2: t2 ]'?
  File "typing/typedtree.mli", line 264, characters 12-29:
  Warning: '{ E0 with t2=P2 }': bad markup.
  Suggestion: did you mean '{! E0 with t2=P2 }' or '[ E0 with t2=P2 ]'?
  File "typing/typedtree.mli", line 266, character 14 to line 267, character 47:
  Warning: '{ fields = [| l1, Kept t1; l2 Override P2 |]; representation;
                  extended_expression = Some E0 }': bad markup.
  Suggestion: did you mean '{! fields = [| l1, Kept t1; l2 Override P2 |]; representation;
                  extended_expression = Some E0 }' or '[ fields = [| l1, Kept t1; l2 Override P2 |]; representation;
                  extended_expression = Some E0 ]'?
  File "toplevel/toploop.mli", line 202, characters 50-50:
  Warning: End of text is not allowed in '[...]' (code).
  File "lib/svg_sigs.mli", line 1054, characters 8-84:
  Warning: '{%...%}' (raw markup) needs a target language.
  Suggestion: try '{%html:...%}'.
  File "lambda/tmc.mli", line 30, character 4 to line 36, character 6:
  Warning: '{|
       let[@tail_mod_cons] rec map f = function
       | [] -> []
       | x :: xs ->
         let y = f x in
         y :: map f xs
      |}': bad markup.
  Suggestion: did you mean '{!|
       let[@tail_mod_cons] rec map f = function
       | [] -> []
       | x :: xs ->
         let y = f x in
         y :: map f xs
      |}' or '[|
       let[@tail_mod_cons] rec map f = function
       | [] -> []
       | x :: xs ->
         let y = f x in
         y :: map f xs
      |]'?
  File "lambda/tmc.mli", line 39, character 4 to line 54, character 6:
  Warning: '{|
       let rec map f = function
       | [] -> []
       | x :: xs ->
         let y = f x in
         let dst = y :: Placeholder in
         map_dps dst 1 f xs; dst
       and map_dps dst offset f = function
       | [] ->
         dst.offset <- []
       | x :: xs ->
         let y = f x in
         let dst' = y :: Placeholder in
         dst.offset <- dst';
         map_dps dst 1 f fx
      |}': bad markup.
  Suggestion: did you mean '{!|
       let rec map f = function
       | [] -> []
       | x :: xs ->
         let y = f x in
         let dst = y :: Placeholder in
         map_dps dst 1 f xs; dst
       and map_dps dst offset f = function
       | [] ->
         dst.offset <- []
       | x :: xs ->
         let y = f x in
         let dst' = y :: Placeholder in
         dst.offset <- dst';
         map_dps dst 1 f fx
      |}' or '[|
       let rec map f = function
       | [] -> []
       | x :: xs ->
         let y = f x in
         let dst = y :: Placeholder in
         map_dps dst 1 f xs; dst
       and map_dps dst offset f = function
       | [] ->
         dst.offset <- []
       | x :: xs ->
         let y = f x in
         let dst' = y :: Placeholder in
         dst.offset <- dst';
         map_dps dst 1 f fx
      |]'?
  File "typing/patterns.mli", line 102, characters 27-28:
  Warning: Unpaired ']' (end of code).
  Suggestion: try '\]'.
  File "lib/html_sigs.mli", line 141, character 6 to line 144, character 8:
  Warning: Code blocks should be indented at the opening `{`.
  File "lib/html_sigs.mli", line 1187, characters 4-85:
  Warning: '{%...%}' (raw markup) needs a target language.
  Suggestion: try '{%html:...%}'.
  File "lib/svg_f.mli", line 26, characters 4-85:
  Warning: '{%...%}' (raw markup) needs a target language.
  Suggestion: try '{%html:...%}'.
  File "driver/compile.mli", line 24, characters 27-28:
  Warning: Paragraph should begin on its own line.
  File "lib/html_f.mli", line 24, characters 4-85:
  Warning: '{%...%}' (raw markup) needs a target language.
  Suggestion: try '{%html:...%}'.
  File "middle_end/flambda/flambda.mli", line 392, character 27 to line 394, character 41:
  Warning: '{ f x ->
              let applied_function = Symbol f_closure in
              Apply (applied_function, x) }': bad markup.
  Suggestion: did you mean '{! f x ->
              let applied_function = Symbol f_closure in
              Apply (applied_function, x) }' or '[ f x ->
              let applied_function = Symbol f_closure in
              Apply (applied_function, x) ]'?
  File "middle_end/flambda/simple_value_approx.mli", line 107, character 25 to line 109, character 4:
  Warning: Blank line is not allowed in '[...]' (code).
  File "driver/optcompile.mli", line 25, characters 27-28:
  Warning: Paragraph should begin on its own line.
  File "testlib.mli", line 5, characters 8-56:
  Warning: Failed to resolve reference /odoc/odoc_for_authors Path '/odoc/odoc_for_authors' not found

Check that documentation was generated:

  $ ls _build/default/_doc/_html/testpkg/testpkg.lib/Testlib/index.html
  _build/default/_doc/_html/testpkg/testpkg.lib/Testlib/index.html

Check that references to Odoc_parser types are remapped to ocaml.org:

  $ grep -o 'href="[^"]*Odoc_parser[^"]*"' _build/default/_doc/_html/testpkg/testpkg.lib/Testlib/index.html | sed 's|/[0-9.]*-*[a-z0-9]*/doc|/VERSION/doc|g' | sort -u
  href="../../../odoc-parser/odoc-parser/Odoc_parser/Loc/index.html#type-span"
  href="../../../odoc-parser/odoc-parser/Odoc_parser/Warning/index.html#type-t"
  href="../../../odoc-parser/odoc-parser/Odoc_parser/index.html#type-t"
  href="../../../odoc-parser/odoc-parser/Odoc_parser/index.html#val-parse_comment"

Check that page references to documentation dependencies are also remapped:

  $ grep -o 'href="[^"]*odoc_for_authors[^"]*"' _build/default/_doc/_html/testpkg/testpkg.lib/Testlib/index.html | sed 's|/[0-9.]*-*[a-z0-9]*/doc|/VERSION/doc|g'
  [1]
