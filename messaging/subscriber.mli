module type Subscriber_info = sig
    type encoding = string
    type header

    val decode_header : encoding -> header option
    (** Used to deserialize a header. *)

    val ping : int64 -> encoding
    (** Creates a message for send a ping. *)

    val handle_message : header -> encoding -> unit
    (** The handler for the incoming message. *)

end

(** Used to create something to handle a subscriber.*)
module Make_Subscriber_info_zeromq(S: Subscriber_info) : sig
    type t

    val make : Host_manager.host_id -> Host_manager.service_id -> Host_manager.t -> t

    val listen : t -> unit
end