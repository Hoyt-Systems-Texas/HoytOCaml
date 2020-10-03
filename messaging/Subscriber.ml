module type SubscriberInfo = sig
    type encoding = string
    type header

    (* Used to deserialize a header. *)
    val decodeHeader : encoding -> header

    (* Creates a message for send a ping. *)
    val ping : int64 -> encoding

    (* The handler for the incoming message. *)
    val handleMessage : header -> encoding -> unit

end

(* Used to create something to handle a subscriber.*)
module Make_SubscriberInfoZeromq(S: SubscriberInfo) = struct
    type t = {
        serverId: int32;
        serviceId: int32;
        hosts: HostManager.t;
    }

    let make serverId serviceId hosts =
        {
            serverId=serverId;
            hosts=hosts;
            serviceId=serviceId;
        }

    let listen t =
        let service = HostManager.getServiceId t.hosts t.serviceId in
        match service with
        | Some s -> (
            let service = List.fold_left (fun found s -> 
                match found with
                | Some s -> Some s
                | None -> (match s with
                    | HostManager.HostEntry.Subscription s -> Some s
                    | _ -> None
                )) None s.hosts in
            match service with
            | Some _ -> ()
            | None -> ()
        )
        | None -> ()

end