open! Core

module Pending_message = struct

    type 'a t =
        | Timeout
        | Message of 'a * string
        | Full
        | UnableToRoute

end

module Message_type = struct

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