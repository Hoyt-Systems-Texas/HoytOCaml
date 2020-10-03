open Core
open Lwt.Infix

module type Request_processor = sig
    type encoding = string
    type header

    (* Used to decode the header of the message. *)
    val decode_header : encoding -> header option

    (* Used to handle the incoming of the message. *)
    val handle_message : header -> encoding -> (encoding * encoding) Lwt.t
end

module Make_Request_processor(R: Request_processor) = struct

    type state = 
        | Idle
        | Running
    
    type t = {
        host_id: Host_manager.host_id;
        service_id: Host_manager.service_id;
        host_manager: Host_manager.t;
        bind_url: string;
        context: Zmq.Context.t;
        state: state ref;
    }

    (* Creates a new request processor. *)
    let make ctx bind_url host_id service_id host_manager =
        {
            host_id;
            service_id;
            host_manager;
            bind_url;
            context=ctx;
            state=ref Idle;
        }

    (* Starts the process for listening on the socket. *)
    let listen (t: t) =
        match !(t.state) with
        | Idle ->
            t.state := Running;
            let socket = Zmq.Socket.create t.context Zmq.Socket.pull in
            let socket_lwt = Zmq_lwt.Socket.of_socket socket in
            let rec handler_loop () =
                Zmq_lwt.Socket.recv socket_lwt
                >>= fun msg -> (
                    match (R.decode_header msg, Zmq.Socket.has_more socket) with
                    | (Some header, true) -> Zmq_lwt.Socket.recv socket_lwt
                        >>= fun msg -> R.handle_message header msg
                        >>= fun (_,_) -> Lwt.return_unit
                    | _ -> Lwt.return_unit)
                >>= fun _ -> (handler_loop [@tailcall]) () in
            handler_loop ()
        | Running -> Lwt.return_unit

end