open! Core

module Test_connection_info = struct 

    type header = Message.Header.t

    let deserialize_header h =
        let reader = Ocaml_protoc_plugin.Reader.create h in
        match Message.Header.from_proto reader with
        | Ok h -> Some h
        | Error(_) -> None

    let get_correlation_id (header: Message.Header.t) =
        header.correlationId

    let get_respond_host_id _ =
        1l
end

module Test_connection_manager = Hoyt_messaging.Connection_manager.Make_connections(Test_connection_info)

module Router_info = struct 

    type encoding = string
    type header = Message.Header.t
    type connection_manager = Test_connection_manager.t

    let decode_header b = 
        let result = Ocaml_protoc_plugin.Reader.create b in 
        match Message.Header.from_proto result with
        | Ok h -> Some h
        | Error(_) -> None

    let get_service_id (header: header) =
        header.toId

    let get_user_id (header: header) =
        header.userId

    let get_from_id (header: header) =
        header.fromId

    let get_message_type (header: header) =
        let module H_M_T = Hoyt_messaging.Messaging.Message_type in
        let module M_H_T = Message.Header.MessageType in
        match header.messageType with
        | M_H_T.PING -> H_M_T.Ping
        | M_H_T.PONG -> H_M_T.Pong
        | M_H_T.STATUS -> H_M_T.Status
        | M_H_T.REQ -> H_M_T.Req
        | M_H_T.REPLY -> H_M_T.Reply
        | M_H_T.EVENT -> H_M_T.Event

    let send_msg = Test_connection_manager.send_reply
end

module Router_test = Hoyt_messaging.Router.Make_Service_router(Router_info)


module Test_processor = struct
    type encoding = string
    type header = Message.Header.t
    type connection_manager = Test_connection_manager.t

    let decode_header b = 
        let result = Ocaml_protoc_plugin.Reader.create b in 
        match Message.Header.from_proto result with
        | Ok h -> Some h
        | Error(_) -> None

    let handle_message header body =
        let header = {
            header with 
            Message.Header.messageType = Message.Header.MessageType.REPLY} in
        let header = Message.Header.to_proto header in
        Lwt.return (Ocaml_protoc_plugin.Writer.contents header, body)

    let message_type (header: Message.Header.t) =
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
    
    let resolve = Test_connection_manager.resolve
end

module Service_processor = Hoyt_messaging.Rpc.Make_Request_processor(Test_processor)

let () =
    let ctx = Zmq.Context.create () in
    let host_id = 100l in
    let bind_url = "tcp://*:6000" in
    let module H_c = Test_connection_manager in
    let host_manager = Hosts_config.create_host_manager host_id in
    let connections = H_c.make ctx host_manager in 
    let router = Router_test.make 
        ctx 
        bind_url
        host_manager
        connections in 
    Lwt_main.run @@
        Router_test.listen router
        


