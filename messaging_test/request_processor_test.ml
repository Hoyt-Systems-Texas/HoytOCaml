open! Core

module Test_processor = struct
    type encoding = string
    type header = string

    let decode_header b = Some b
    let handle_message header body =
        print_endline header;
        print_endline body;
        Lwt.return ("s", "e")
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