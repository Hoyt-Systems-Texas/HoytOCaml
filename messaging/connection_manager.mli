open! Core

module type Connection_info = sig
    type header
    
    val get_correlation_id : header -> int64
    (* [get_correlation_id header] Gets the correlation id of the message from the [header]. *)

    val get_respond_host_id : header -> int32
    (* [get_respond_host_id header] Gets the responding host id of the message from the [header]. *)

end

module Make_connections(M: Connection_info) : sig
    type t 

    val send_msg: t -> Host_manager.host_id -> int64 -> string -> string -> M.header Messaging.Pending_message.t Lwt.t
    (** 
      [send_msg t host_id correlation_id header body]
      [t] is used to manage the connections to other systems.
      [correlation_id] the correlation id of the message to send.
      [host_id] The id of the host to connect to.
      [header] The encoding header to send.
      [body] The body of the message to send.
     *)

    val send_reply: t -> Host_manager.host_id -> string -> string -> unit Lwt.t
    (** [send_reply connection_manager host_id header body] is used to send a reply to a manage for RPC.
      [t] the connection manager.
      [host_id] the id of the host to send the reply too.
      [header] the serialized header to send back.
      [body] the serialized body to send back.
     *)

    val next_id: t -> int64
    (** [next_id t] used to get the next correlation id to use. 
     *)

    val terminate: t -> unit
    (** [terminate t] closes all of the sockets that are currently opened. *)

    val routable_message: t -> Host_manager.host_id -> string -> string -> unit Lwt.t
    (** [routable_message t host_id header body] used to route the message. 
      [t] the id of the hosts.
      [host_id] the id of the host to route the message to.
      [header] The header of the message to send.
      [body] the body of the message to send back.*)

     val send_to_router: t -> int64 -> string -> string -> M.header Messaging.Pending_message.t Lwt.t
     (** [send_to_router t correlation_id header body] used to send a message to the router.
       [t] the connection manager.
       [correlation_id] the id of the correlation id.
       [header] the header of the message to send.
       [body] the body of the message to send.
      *)

    val resolve: t -> M.header -> string -> unit Lwt.t
    (** [resolve t header body] called to resolve a reply message.
      [t] the connection manager.
      [header] the decoded header to resolve.
      [body] the body of the message. 
     *)

    val make: Zmq.Context.t -> Host_manager.t -> t
    (** [make ctx host_manager]
      [ctx] the zeromq context used to context.
      [host_manager] the host manager to handle the connections.
     *)

end 