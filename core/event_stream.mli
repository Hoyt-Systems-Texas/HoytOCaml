open! Core

module type Event_stream_type = sig
  type record
  (** The event we are processing. *)

  val handler: id:int64 -> data:record -> unit
  (** Handles a new message being received from the event store. [id] is the id assigned to the message. [data] is the data associated with the id.*)
end

module Make_event_stream(E: Event_stream_type) : sig

  type t

  val make: int32 -> t option
  (** Creates a new event stream. *)

  val add: t -> E.record -> unit
  (** Adds a value to the event stream. *)

  val get: t -> int64 -> E.record option
  (** Gets a value from the event stream. *)


end