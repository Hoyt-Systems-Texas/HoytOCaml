open! Core

module type Event_stream_type = sig
  type record
  (** The event we are processing. *)

  val handler: id:int64 -> data:record -> unit
  (** Handles a new message being received from the event store. [id] is the id assigned to the message. [data] is the data associated with the id.*)
end

module Make_event_stream(E: Event_stream_type) = struct

  type t = {
    buffer: E.record Ring_buffer.t;
  }

  let make size =
    match Ring_buffer.make size 0L with
    | Some b -> Some {
      buffer=b;
    }
    | None -> None

  let add t record =
    let id = Ring_buffer.add t.buffer record in
    E.handler ~id ~data:record

  let get t id =
    Ring_buffer.get t.buffer id

end