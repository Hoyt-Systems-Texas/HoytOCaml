open! Core

module Test_processor = struct
    type encoding = string
    type header = Message.Header.t

    let decode_header b = 
        let result = Ocaml_protoc_plugin.Reader.create b in 
        match Message.Header.from_proto result with
        | Ok h -> Some h
        | Error(_) -> None

    let handle_message _ body =
        print_endline body;
        Lwt.return ("s", "e")

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
        
end

module Service_processor = Hoyt_messaging.Rpc.Make_Request_processor(Test_processor)

let hosts = [
    {
        Hoyt_messaging.Host_manager.Host_entry.host_id=1l;
        service_id=Some 1l;
        sub_socket="tcp://localhost:5001";
        push_socket="tcp://localhost:5002";
        pull_socket="tcp://localhost:4000";
    };
    {
        host_id=2l;
        service_id=Some 2l;
        sub_socket="tcp://localhost:5003";
        push_socket="tcp://localhost:5004";
        pull_socket="tcp://localhost:4001";
    }
]


let () =
    let ctx = Zmq.Context.create () in 
    let host_id = 1l in
    let service_id = 1l in 
    let bind_url = "tcp://*:5002" in 
    let host_manager = Hoyt_messaging.Host_manager.make 1l in
    let host_manager = Hoyt_messaging.Host_manager.load host_manager hosts in
    let processor = Service_processor.make ctx bind_url host_id service_id host_manager in
    Lwt_main.run @@ Service_processor.listen processor