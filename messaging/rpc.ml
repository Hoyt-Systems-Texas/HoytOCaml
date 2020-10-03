module type Request_processor = sig
    type encoding = string
    type header

    (* Used to decode the header of the message. *)
    val decode_header : encoding -> header option

    (* Used to handle the incoming of the message. *)
    val handle_message : header -> encoding -> (encoding * encoding)
end

module Make_Request_processor(R: Request_processor) = struct
    
    type t = {
        host_id: Host_manager.host_id;
        service_id: Host_manager.service_id;
        host_manager: Host_manager.t;
        pull_socket: [`Push] Zmq.Socket.t;
    }

    (* Creates a new request processor. *)
    let make ctx host_id service_id host_manager =
        {
            host_id;
            service_id;
            host_manager;
            pull_socket=Zmq.Socket.create ctx Zmq.Socket.push;
        }

    (* Starts the process for listening on the socket. *)
    let listen (_: t) =
        ()

end