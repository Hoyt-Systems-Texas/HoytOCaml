module type Service_router_info = sig
    type encoding = string
    type header
    type connection_manager

    val decode_header:  encoding -> header option

    val get_service_id: header -> int32
    (** The id of the service to send the message to. *)

    val get_user_id: header -> int64
    (** Gets the id of the user who is making the request. *)

    val get_from_id: header -> Host_manager.host_id
    (** Gets the id of the from host. *)

    val get_message_type: header -> Messaging.Message_type.t
    (** Used to get the message type. *)

    val send_msg: connection_manager -> Host_manager.host_id -> encoding -> encoding -> unit Lwt.t
    (** Sends a message to a host. *)
end

module Make_Service_router(I: Service_router_info) : sig

    type t

    val make : Zmq.Context.t ->
        string ->
        Host_manager.t ->
        I.connection_manager ->
        t
    (** Creates a new router.
      Arguments:
      ctx - The zmq context to use to create the conenctions.
      bind_address - The binding address for the socket.
      host_manager - The host manager.
     *)

    val listen : t -> unit Lwt.t
    (** Starts the main listener to forward the messages. *)
end