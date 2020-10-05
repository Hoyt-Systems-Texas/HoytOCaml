open! Core

type t 

(* Used to send a message to the host with the specified id. 
 * Arguments:
 * connection_manager - The connection manager.
 * host_id - The id of the host to send messages to.
 * header - The header of the message to send.
 * body - The body of the message to send.
 *)
val send_msg: t -> Host_manager.host_id -> string -> string -> unit Lwt.t

val make: Zmq.Context.t -> Host_manager.host_id -> Host_manager.t -> t