(** A library that depends on the external [unix] library. *)

let now () = Unix.gettimeofday ()
