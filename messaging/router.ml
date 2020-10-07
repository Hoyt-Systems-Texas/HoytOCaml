open! Core
open Lwt.Infix

module type Service_router_info = sig
    type encoding = string
    type header

    val decode_header:  encoding -> header option

    (* The id of the service to send the message to. *)
    val get_service_id: header -> int32

    (* Gets the id of the user who is making the request. *)
    val get_user_id: header -> int64

    (* Used to get the message type. *)
    val get_message_type: header -> Messaging.Message_type.t

end

module Make_Service_router(I: Service_router_info) = struct

    type t = {
        ctx: Zmq.Context.t;
        binding_address: string;
        host_manager: Host_manager.t;
        send_msg: Messaging.send_msg;
    }

    let make ctx binding_address host_manager send_msg =
        {
            ctx;
            binding_address;
            host_manager;
            send_msg;
        }

    let handle_ping _ _ =
        Lwt.return_unit

    let handle_pong _ _ =
        Lwt.return_unit

    let handle_req _ _ _ =
        Lwt.return_unit

    let handle_reply _ _ _ =
        Lwt.return_unit

    let handle_event _ _ _ =
        Lwt.return_unit
    
    let handle_status _ _ _ =
        Lwt.return_unit

    let route_msg t header body =
        let module M_t = Messaging.Message_type in
        match I.decode_header header with
        | Some h -> 
            (match I.get_message_type h with 
            | M_t.Ping -> handle_ping t h
            | M_t.Pong -> handle_pong t h
            | M_t.Req -> handle_req t (header, h) body
            | M_t.Reply -> handle_reply t (header, h) body
            | M_t.Event -> handle_event t (header, h) body
            | M_t.Status -> handle_status t (header, h) body)
        | None -> Lwt.return_unit

    let listen t =
        let pull_socket = Zmq.Socket.create t.ctx Zmq.Socket.pull in 
        let pull_socket_lwt = Zmq_lwt.Socket.of_socket pull_socket in 
        let rec spin_loop () =
            Zmq_lwt.Socket.recv pull_socket_lwt
            >>= (fun header -> 
                match Zmq.Socket.has_more pull_socket with
                | true -> 
                    Zmq_lwt.Socket.recv pull_socket_lwt
                    >>= (fun body -> route_msg t header body)
                    >>= (fun _ -> (spin_loop [@tailcall]) ())
                | false -> Lwt.return_unit) in 
        spin_loop ()
end