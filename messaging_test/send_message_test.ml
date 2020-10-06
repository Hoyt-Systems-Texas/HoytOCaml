open! Core
open Lwt.Infix

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

let () =
    let module H_m = Hoyt_messaging.Host_manager in 
    let module H_c = Test_connection_manager in
    let manager = H_m.make 1l in 
    let manager = H_m.load manager hosts in
    let ctx = Zmq.Context.create () in
    let connections = H_c.make ctx manager "tcp://*:4001" in
    let corr_id = H_c.next_id connections in
    Lwt_main.run
        (H_c.start_loop connections |> Lwt.ignore_result;
            Lwt.return_unit
        >>= fun _ -> H_c.send_msg connections 1l corr_id "h" "m"
        >>= (fun _ -> print_endline "Message sent..."; 
            ignore (H_c.terminate connections: bool);
            Zmq.Context.terminate ctx;
            Lwt.return_unit));
    ()