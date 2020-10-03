module type Subscriber_info = sig
    type encoding = string
    type header

    (* Used to deserialize a header. *)
    val decode_header : encoding -> header option

    (* Creates a message for send a ping. *)
    val ping : int64 -> encoding

    (* The handler for the incoming message. *)
    val handle_message : header -> encoding -> unit

end

(* Used to create something to handle a subscriber.*)
module Make_Subscriber_info_zeromq(S: Subscriber_info) : sig
    type t

    val make : Host_manager.host_id -> Host_manager.service_id -> Host_manager.t -> t

    val listen : t -> unit
end