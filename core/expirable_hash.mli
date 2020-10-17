open! Core

type ('k, 'v) t

val make : 
  (module Hash_set.Elt_plain with type t = 'k) -> 
  Time_ns.Span.t ->
  ('k, 'v) t
(** Creates a new expirable hash queue.  The queue doesn't delete values
imediatedly when expired.*)

val clean: ('k, 'v) t -> unit
(** Cleans out the old records for the data structure. *)

val add : ('k, 'v) t -> 'k -> 'v -> [`Ok | `Duplicate ]
(** Used to add a value to the queue *)

val get : ('k, 'v) t -> 'k -> 'v option
(** Gets the value out of the collection. *)

val remove: ('k, 'v) t -> 'k -> unit
(** Removes a value from the record. *)