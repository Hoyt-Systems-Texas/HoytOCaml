open! Core

module DataStoreResult : sig

  type 'v t = 
    | NoValue
    | Available of 'v
    | Error

end

module type Data_type = sig
  type key
  (** The data type for the key. *)

  type record
  (** The type of the record to get. *)

  val fetch: key -> record DataStoreResult.t Lwt.t
  (** Used to fetch a value from the database. *)

end

module Make_data_type(D: Data_type) : sig
  type t
  (** The collection type. *)

  val make : (module Hash_set.Elt_plain with type t = D.key) -> t
  (** Creates a new in memory collection. *)

  val update : t -> D.key -> D.record -> unit
  (** Used to add or update a value in the database. *)

  val get : t -> D.key -> D.record DataStoreResult.t Lwt.t
  (** Used to get a value from the cache. *)
end
