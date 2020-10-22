open! Core

module type Request_processor = sig
  include Common.Common_processor

  type t

  val handle_message : header -> encoding -> (encoding * encoding) Lwt.t
  (** Used to handle the incoming of the message. *)

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
      R.t ->
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