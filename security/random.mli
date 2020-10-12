open! Core

val session : int -> string
(** Used to generate a session key at the specified length.  It gets encoded to a valid
string so it can be sent to a browser. *)