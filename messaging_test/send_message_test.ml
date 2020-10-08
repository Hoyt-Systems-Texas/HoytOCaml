open! Core
open Lwt.Infix

let () =
    let module H_m = Hoyt_messaging.Host_manager in 
    let module H_c = Reply_processor.Test_connection_manager in
    let manager = Hosts_config.create_host_manager 1l in 
    let bind_url = "tcp://*:5004" in 
    let ctx = Zmq.Context.create () in
    let connections = H_c.make ctx manager in
    let rpc = Reply_processor.Service_processor.make 
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
        (Reply_processor.Service_processor.listen rpc |> Lwt.ignore_result; Lwt.return_unit
        >>= (fun _ -> H_c.send_msg connections 1l corr_id header "m")
        >>= (fun _ -> print_endline "Message sent..."; 
            H_c.terminate connections;
            Zmq.Context.terminate ctx;
            Lwt.return_unit));
    ()