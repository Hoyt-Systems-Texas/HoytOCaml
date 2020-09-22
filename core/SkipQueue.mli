type 'a t

val make : unit -> 'a t

val enqueue : 'a t -> 'a -> unit 
val dequeue : 'a t -> 'a option
val defer : 'a t -> 'a -> unit
val reset : 'a t -> unit