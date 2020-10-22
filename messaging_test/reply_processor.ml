(** A default reply processor that doesn't handle request messages. *)
open! Core
open! Lwt.Infix
module Test_connection_manager = Config.Test_connection_manager

module Test_processor = struct 
    type t = unit
    include Config.Connection_common

    let handle_message header body =
        let header = {
            header with 
            Message.Header.messageType = Message.Header.MessageType.REPLY} in
        let header = Message.Header.to_proto header in
        Lwt.return (Ocaml_protoc_plugin.Writer.contents header, body)
    
    let resolve  = Test_connection_manager.resolve
end

module Service_processor = Hoyt_messaging.Rpc.Make_Request_processor(Test_processor)