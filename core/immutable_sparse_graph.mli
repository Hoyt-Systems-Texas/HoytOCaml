(** A sparse graph design to encode graph information in a small amount of memory. *)

type 'a t

(** The type for the edges in the graph. *)
type 'a edges = ('a * 'a)

(** Createa a new sparse graph.
@param edges The edges to use to build the graph.  Must be in order of the first edge. 
@param default_value The default value to use for the edge. *)
val make: 'a edges list -> 'a -> 'a t option

(** Used to find all of the edges.
@param graph The sparse graph to search.
@param vertex The vertex to find and get all of it's edges. 
@return The list of vertexes that match with the starting edge. *)
val find: 'a t -> 'a -> 'a list

(** Does a breadth first search. 
@param graph The graph to perform the search on.
@param start-vertex The starting vertex to search for.
@param end-vertex Thee ending vertex to stop at.
@returns The path to the value. *)
val bfs: 'a t -> 'a -> 'a -> 'a list option