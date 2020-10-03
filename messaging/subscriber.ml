module type Subscriber_info = sig
    type encoding = string
    type header

    (* Used to deserialize a header. *)
    val decode_header : encoding -> header option

    (* Creates a message for send a ping. *)
    val ping : int64 -> encoding

    (* The handler for the incoming message. *)
    val handle_message : header -> encoding -> unit

end

(* Used to create something to handle a subscriber.*)
module Make_Subscriber_info_zeromq(S: Subscriber_info) = struct
    type t = {
        server_id: int32;
        service_id: int32;
        hosts: Host_manager.t;
    }

    let make server_id service_id hosts =
        {
            server_id=server_id;
            hosts=hosts;
            service_id=service_id;
        }

    let listen t =
        let service = Host_manager.get_service_id t.hosts t.service_id in
        match service with
        | Some _ -> ()
        | None -> ()

end