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
        hosts: HostManager.t;
    }

    let make hosts =
        {
            serverId=0l;
            hosts=hosts;
        }


end