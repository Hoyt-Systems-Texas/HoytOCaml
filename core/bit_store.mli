(** Used to store as efficient as possible in bits of an int64.  It is useful for 
searching for data and keeping it small so if fits into the cpu caches.  Uses the BigArray
type to prevent boxing of the values. *)

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

(** Reads in a value at a position.
@param t The bit store containing the information.
@param pos The position to read in.
@returns The value at that position or none. *)
val read_opt: t -> int64 -> int64 option

(** writes a value at the position.
@param t The bit store to update with theh new value.
@param pos The position to write the value to.
@param value The value to write at that position. *)
val write: t -> int64 -> int64 -> unit

(** Does a binary search on the bit stream.  The bit store must be ordered and does suupport
 duplicate values.
@param t The bit store to perform the binary stream on.
@param val The value to search for.
@param increments The increments to search the btrere for.
@returns The position of the value found. *)
val binary_search: t -> int64 -> int64 -> int64 option

(** Clones the bit store with the new size.
@param t The bit store to clone.
@param new_size The new size of the bit store.
@returns The cloned bit store.*)
val clone: t -> int -> t

(** Creates a new bit store with the same settings.
@param t The bit store to copy the settings for.
@param size The size of the bit store.
@returns The new bit store. *)
val create_new: t -> int -> t