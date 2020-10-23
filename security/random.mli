open! Core

val session : int -> string
(** Used to generate a session key at the specified length.  It gets encoded to a valid
string so it can be sent to a browser. *)

val random_int64 : unit -> int64
(** Generates a securely random int64 value. *)