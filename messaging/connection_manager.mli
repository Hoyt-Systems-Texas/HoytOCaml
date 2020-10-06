open! Core

module type Connection_info = sig
    type header
    
    val deserialize_header : string -> header option

    val get_correlation_id : header -> int64

    val get_respond_host_id : header -> int32

end

module Make_connections(M: Connection_info) : sig
    type t 

    (* Used to send a message to the host with the specified id.  Expects to get a result for rpc calls
     * Arguments:
     * connection_manager - The connection manager.
     * host_id - The id of the host to send messages to.
     * header - The header of the message to send.
     * body - The body of the message to send.
     *)
    val send_msg: t -> Host_manager.host_id -> int64 -> string -> string -> M.header Messaging.Pending_message.t Lwt.t

    (* Used to send a reply message to the pull socket of the host. 
     * Arguments:
     * t - The connection manager.
     * host_id - The id of the host to send the reply too.
     * header - The serialized header to send back.
     * body - The serialized body to send back. 
    val send_reply: t -> Host_manager.host_id -> string -> string -> unit Lwt.t
    *)

    (*
    * Used to get the next correlation id to use.
    *)
    val next_id: t -> int64

    (* Closes all of the sockets that are currently opened.
     *)
    val terminate: t -> bool

    (* Creates a new connection manager. 
     * Arguments:
     * ctx - The zeromq ctx.
     * host_manager - The host manager to handle the connections.
     * rpc - The rpc socket manager. *)
    val make: Zmq.Context.t -> Host_manager.t -> string -> t

    (* Starts the main loop for handling the replies. *)
    val start_loop: t -> unit Lwt.t
end 