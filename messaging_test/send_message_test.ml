open! Core
open Lwt.Infix

let hosts = [
    {
        Hoyt_messaging.Host_manager.Host_entry.host_id=1l;
        service_id=Some 1l;
        name="test service 1";
        sub_socket="tcp://localhost:5001";
        push_socket="tcp://localhost:5002";
        pull_socket="tcp://*:5002";
    };
    {
        host_id=2l;
        service_id=Some 2l;
        name="test service 2";
        sub_socket="tcp://localhost:5003";
        push_socket="tcp://localhost:5004";
        pull_socket="tcp://*:5004";
    }
]

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

let () =
    let module H_m = Hoyt_messaging.Host_manager in 
    let module H_c = Test_connection_manager in
    let manager = Hosts_config.create_host_manager 1l in 
    let bind_url = "tcp://*:5004" in 
    let ctx = Zmq.Context.create () in
    let connections = H_c.make ctx manager in
    let rpc = Service_processor.make 
        ctx 
        bind_url 
        2l 
        2l 
        manager
        connections in
    let corr_id = H_c.next_id connections in
    let messageType = Message.Header.MessageType.REQ in
    let payloadType = Some (`User Message.UserMessage.CreateUser) in
    let status = Message.Header.Status.NA in
    let header = {
        Message.Header.fromId=2l;
        Message.Header.toId=2l;
        correlationId=corr_id;
        userId=1L;
        organizationId=1l;
        messageType;
        payloadType;
        status;
    } in
    let header = Message.Header.to_proto header in
    let header = Ocaml_protoc_plugin.Writer.contents header in
    Lwt_main.run
        (Service_processor.listen rpc |> Lwt.ignore_result; Lwt.return_unit
        >>= (fun _ -> H_c.send_msg connections 1l corr_id header "m")
        >>= (fun _ -> print_endline "Message sent..."; 
            H_c.terminate connections;
            Zmq.Context.terminate ctx;
            Lwt.return_unit));
    ()