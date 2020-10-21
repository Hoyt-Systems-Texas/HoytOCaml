open! Core

type 'a t

val make: int32 -> int64 -> 'a t option
(** Creats a new buffer. [size] of the ring buffer. [start_num] the starting number for the buffer.*)

val get: 'a t -> int64 -> 'a option
(** Used to get a value out of the buffer.*)

val add: 'a t -> 'a -> int64
(** Adds a value to the buffer shifting the value. *)

val min_index: 'a t -> int64
(** The min index available in the buffer. *)

val size: 'a t -> int32
(** The size of the ring buffer. *)