(** A default reply processor that doesn't handle request messages. *)
open! Core
open! Lwt.Infix

module Test_connection_info = struct 

    type header = Message.Header.t

    let deserialize_header h =
        let reader = Ocaml_protoc_plugin.Reader.create h in
        match Message.Header.from_proto reader with
        | Ok h -> Some h
        | Error(_) -> None

    let get_correlation_id (header: Message.Header.t) =
        header.correlationId

    let get_respond_host_id (header: Message.Header.t) =
        header.fromId
end

module Test_connection_manager = Hoyt_messaging.Connection_manager.Make_connections(Test_connection_info)

module Test_processor = struct 
    type t = unit
    type encoding = string
    type header = Message.Header.t
    type connection_manager = Test_connection_manager.t

    let decode_header encoding =
        let reader = Ocaml_protoc_plugin.Reader.create encoding in
        match Message.Header.from_proto reader with
        | Ok header -> Some header
        | Error _ -> None

    let handle_message header body =
        let header = {
            header with 
            Message.Header.messageType = Message.Header.MessageType.REPLY} in
        let header = Message.Header.to_proto header in
        Lwt.return (Ocaml_protoc_plugin.Writer.contents header, body)
    
    let message_type (header: header) =
        let module H_M_T = Hoyt_messaging.Messaging.Message_type in
        let module M_H_T = Message.Header.MessageType in
        match header.messageType with
        | M_H_T.PING -> H_M_T.Ping
        | M_H_T.PONG -> H_M_T.Pong
        | M_H_T.STATUS -> H_M_T.Status
        | M_H_T.REQ -> H_M_T.Req
        | M_H_T.REPLY -> H_M_T.Reply
        | M_H_T.EVENT -> H_M_T.Event

    let from_id (h:header) = h.fromId

    let send_msg = Test_connection_manager.send_reply

    let resolve  = Test_connection_manager.resolve
end

module Service_processor = Hoyt_messaging.Rpc.Make_Request_processor(Test_processor)