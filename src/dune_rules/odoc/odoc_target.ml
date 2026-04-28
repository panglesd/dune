open Import

module Doc_mode = struct
  type t =
    | Local_only
    | Full

  let subdir = function
    | Local_only -> ""
    | Full -> "full"
  ;;

  let all = [ Local_only; Full ]
end

type page =
  { name : string
  ; pkg_libs : Lib.t list
  }

type asset =
  { asset_name : string
  ; asset_rel_path : string
  }

type mod_ =
  { visible : bool
  ; module_name : Module_name.t
  }

type _ t =
  | Lib : Package.Name.t * Lib.t -> mod_ t
  | Private_lib : string * Lib.t -> mod_ t
  | Pkg : Package.Name.t -> page t
  | Toplevel : Doc_mode.t -> page t

type any = Any : 'a t -> any

let compare_any (Any t1) (Any t2) =
  (* Assign a rank to each target type for ordering *)
  let rank : type a. a t -> int = function
    | Pkg _ -> 0
    | Lib _ -> 1
    | Private_lib _ -> 2
    | Toplevel _ -> 3
  in
  let r1 = rank t1 in
  let r2 = rank t2 in
  (* First compare by rank (target type) *)
  match Int.compare r1 r2 with
  | Eq ->
    (* Same rank, so same target type - compare by contents *)
    (match t1, t2 with
     | Pkg p1, Pkg p2 -> Package.Name.compare p1 p2
     | Lib (_, l1), Lib (_, l2) -> Lib_name.compare (Lib.name l1) (Lib.name l2)
     | Private_lib (_, l1), Private_lib (_, l2) ->
       Lib_name.compare (Lib.name l1) (Lib.name l2)
     | Toplevel m1, Toplevel m2 ->
       (* Compare modes: Local_only < Full *)
       (match m1, m2 with
        | Doc_mode.Local_only, Doc_mode.Local_only -> Ordering.Eq
        | Doc_mode.Local_only, Doc_mode.Full -> Ordering.Lt
        | Doc_mode.Full, Doc_mode.Local_only -> Ordering.Gt
        | Doc_mode.Full, Doc_mode.Full -> Ordering.Eq)
     | _ -> assert false (* Ranks are equal, so types must match *))
  | ordering -> ordering
;;
