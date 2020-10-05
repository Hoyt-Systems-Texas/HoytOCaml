module Pending_message = struct

    type 'a t =
        | Timeout
        | Message of 'a * string
        | Full

end