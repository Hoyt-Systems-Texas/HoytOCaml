module Pending_message = struct

    type 'a t =
        | Timeout
        | Message of 'a * string
        | Full

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