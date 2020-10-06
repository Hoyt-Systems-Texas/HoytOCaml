open! Core

module Pending_message : sig

    type 'a t = 
        (* The timeout messag. *)
        | Timeout
        (* We got a response of the message. First value is the header and the second value is the message body. *)
        | Message of 'a * string
        (* The sending queue is full. *)
        | Full

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