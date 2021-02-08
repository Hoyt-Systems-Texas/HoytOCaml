type t

(** Creates a new bit store.
@param size The size of the bit store.
@param bits The number of bits to use for the storage.
@returns The newly created bit store. *)
val make: int64 -> int -> t

(** Gets the length of the bit store. 
@param t The bit store to get the length of.
@returns The length of the bit store.*)
val length: t -> int

(** Reads in a value at a position.
@param t The bit store containign the information.
@param pos The position to read in the value for. 
@returns The value at the position. *)
val read: t -> int64 -> int64

(** writes a value at the position.
@param t The bit store to update with theh new value.
@param pos The position to write the value to.
@param value The value to write at that position. *)
val write: t -> int64 -> int64 -> unit