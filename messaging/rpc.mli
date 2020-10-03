module type Request_processor = sig
    type encoding = string
    type header

    (* Used to decode the header of the message. *)
    val decode_header : encoding -> header option

    (* Used to handle the incoming of the message. *)
    val handle_message : header -> encoding -> (encoding * encoding)
end

module Make_Request_processor(R: Request_processor) : sig
    
    type t

    (* Creates a new request processor. *)
    val make : Zmq.Context.t ->  Host_manager.host_id -> Host_manager.service_id -> Host_manager.t -> t

    (* Starts the process for listening on the socket. *)
    val listen : t -> unit

end