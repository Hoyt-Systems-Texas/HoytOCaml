open Core
open Lwt.Infix

module type Request_processor = sig
    include Common.Common_processor
    type t

    val handle_message : header -> encoding -> (encoding * encoding) Lwt.t
    (** Used to handle the incoming of the message. *)

    val resolve : connection_manager -> header -> encoding -> unit Lwt.t
    (** Resolves a message. *)
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
        connection_manager: R.connection_manager;
        r_t: R.t;
    }

    let make ctx bind_url host_id service_id host_manager connection_manager r_t=
        {
            host_id;
            service_id;
            host_manager;
            bind_url;
            context=ctx;
            state=ref Idle;
            connection_manager;
            r_t;
        }
    (** Creates a new request processor. *)

    let handle_ping t h =
        let h = R.set_message_type h Messaging.Message_type.Pong in
        R.send_msg t.connection_manager (R.from_id h) (R.encode_header h) ""

    let process_message t header msg =
        let module M_T = Messaging.Message_type in
        match R.message_type header with
        | M_T.Req -> 
            R.handle_message header msg 
            >>= (fun (h, b) -> R.send_msg t.connection_manager (R.from_id header) h b)
        | M_T.Reply -> 
            R.resolve t.connection_manager header msg
        | M_T.Event -> Lwt.return_unit
        | M_T.Ping -> handle_ping t header
        | M_T.Pong -> Lwt.return_unit
        | M_T.Status -> Lwt.return_unit

    (* Starts the process for listening on the socket. *)
    let listen t =
        match !(t.state) with
        | Idle ->
            print_endline "Starting the service...";
            t.state := Running;
            let socket = Zmq.Socket.create t.context Zmq.Socket.pull in
            let socket_lwt = Zmq_lwt.Socket.of_socket socket in
            Zmq.Socket.bind socket t.bind_url;
            print_endline ("Bound to url: " ^ t.bind_url);
            let rec handler_loop () =
                Zmq_lwt.Socket.recv socket_lwt
                >>= fun msg -> (
                    match (R.decode_header msg, Zmq.Socket.has_more socket) with
                    | (Some header, true) -> Zmq_lwt.Socket.recv socket_lwt
                        >>= fun msg -> process_message t header msg
                    | (Some _, false ) -> 
                        print_endline "Should be a multipart message!";
                        Lwt.return_unit
                    | _ -> 
                        print_endline ("Invalid header!" ^ msg);
                        Lwt.return_unit)
                >>= fun _ -> (handler_loop [@tailcall]) () in
            handler_loop ()
        | Running -> Lwt.return_unit

end