open! Core

module type Request_processor = sig
    type encoding = string
    type header
    type connection_manager

    val decode_header : encoding -> header option
    (** Used to decode the header of the message. *)

    val handle_message : header -> encoding -> (encoding * encoding) Lwt.t
    (** Used to handle the incoming of the message. *)

    val message_type : header -> Messaging.Message_type.t
    (** Used to get the type of the message. *)

    val from_id : header -> Host_manager.host_id
    (** Gets the id of who the message is from. *)

    val send_msg : connection_manager -> Host_manager.host_id -> encoding -> encoding -> unit Lwt.t
    (** Used to send a message back. *)

    val resolve : connection_manager -> header -> encoding -> unit Lwt.t
    (** Resolves a message. *)

end

module Make_Request_processor(R: Request_processor) : sig
    
    type t

    val make : Zmq.Context.t -> 
        string ->  
        Host_manager.host_id -> 
        Host_manager.service_id -> 
        Host_manager.t -> 
        R.connection_manager ->
        t
    (** Creates a new request processor. 
      Arguments: 
      ctx: Zmq.Context.t - The zmq context
      bind_url - The binding url for the socket.
      host_id - The id for this host.
      service_id - The id for this service.
      host_manager - The host manager containing the location of all the services and hosts.
      decode_header - Decodes the header.
      update_sender - Updates the host id.
     *)

    val listen : t -> unit Lwt.t
    (** Starts the process for listening on the socket. *)

end