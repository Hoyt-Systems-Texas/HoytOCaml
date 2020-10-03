open! Core

module type Request_processor = sig
    type encoding = string
    type header

    (* Used to decode the header of the message. *)
    val decode_header : encoding -> header option

    (* Used to handle the incoming of the message. *)
    val handle_message : header -> encoding -> (encoding * encoding) Lwt.t
end

module Make_Request_processor(R: Request_processor) : sig
    
    type t

    (* Creates a new request processor. 
     * Arguments:
     * ctx: Zmq.Context.t - The zmq context
     * bind_url - The binding url for the socket.
     * host_id - The id for this host.
     * service_id - The id for this service.
     * host_manager - The host manager containing the location of all the services and hosts.
     *)
    val make : Zmq.Context.t -> string ->  Host_manager.host_id -> Host_manager.service_id -> Host_manager.t -> t

    (* Starts the process for listening on the socket. *)
    val listen : t -> unit Lwt.t

end