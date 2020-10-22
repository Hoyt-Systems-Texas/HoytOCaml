module type Common_processor = sig
  type encoding = string
  type header
  type connection_manager

    val decode_header : encoding -> header option
    (** Used to decode the header of the message. *)

    val encode_header : header -> string
    (** Encodes a header with a value. *)

    val message_type : header -> Messaging.Message_type.t
    (** Used to get the message type. *)

    val set_message_type: header -> Messaging.Message_type.t -> header
    (** Sets the message type in the header. *)

    val from_id : header -> Host_manager.host_id
    (** Gets the id of who the message is from. *)

    val send_msg : connection_manager -> Host_manager.host_id -> encoding -> encoding -> unit Lwt.t (** Used to send a message back. *)

end