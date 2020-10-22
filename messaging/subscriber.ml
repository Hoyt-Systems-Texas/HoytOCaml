open Core
open Lwt.Infix

module type Subscriber_info = sig
  include Common.Common_processor

  (* Creates a message for send a ping. *)
  val ping : int64 -> encoding

  (* The handler for the incoming message. *)
  val handle_message : header -> encoding -> unit Lwt.t
end

(* Used to create something to handle a subscriber.*)
module Make_Subscriber_info_zeromq(S: Subscriber_info) = struct
  type t = {
    context: Zmq.Context.t;
    server_id: int32;
    service_id: int32;
    hosts: Host_manager.t;
  }

  let make context server_id service_id hosts =
    {
      context=context;
      server_id=server_id;
      hosts=hosts;
      service_id=service_id;
    }

  let event_loop _t socket =
    let socket_lwt = Zmq_lwt.Socket.of_socket socket in
    let rec handler_loop () =
      Zmq_lwt.Socket.recv socket_lwt
      >>= fun msg -> (
        match (S.decode_header msg, Zmq.Socket.has_more socket) with
        | (Some header, true) -> 
          Zmq_lwt.Socket.recv socket_lwt
          >>= fun msg -> S.handle_message header msg
        | _ -> Lwt.return_unit
      )
      >>= fun _ -> handler_loop () in
    handler_loop ()

  let listen t =
    let service = Host_manager.get_service_id t.hosts t.service_id in
    match service with
    | Some h -> 
      let h = h.hosts in
      (match List.hd h with 
      | Some h -> 
        let socket = Zmq.Socket.create t.context Zmq.Socket.sub in
        Zmq.Socket.connect socket h.sub_socket;
        event_loop t socket;
      | None -> Lwt.return_unit)
    | None -> Lwt.return_unit

end