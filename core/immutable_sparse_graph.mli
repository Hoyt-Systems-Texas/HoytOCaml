(** A sparse graph design to encode graph information in a small amount of memory. *)

type 'a t

(** The type for the edges in the graph. *)
type 'a edges = ('a * 'a)

(** Createa a new sparse graph.
@param edges The edges to use to build the graph.  Must be in order of the first edge. 
@param default_value The default value to use for the edge. *)
val make: 'a edges list -> 'a -> 'a t option