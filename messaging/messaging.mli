open! Core

module Pending_message : sig

    type 'a t = 
        | Timeout
        (** The timeout messag. *)
        | Message of 'a * string
        (** We got a response of the message. First value is the header and the second value is the message body. *)
        | Full
        (** The sending queue is full. *)
        | UnableToRoute
        (** Failed to route the message to the correct host. *)

end

module Message_type : sig

    type t =
        | Ping
        | Pong
        | Req
        | Reply
        | Event
        | Status
end

type encoding = string

type send_msg = (Host_manager.host_id -> encoding -> encoding -> unit Lwt.t)