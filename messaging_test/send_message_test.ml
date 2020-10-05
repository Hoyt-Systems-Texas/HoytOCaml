open! Core
open Lwt.Infix

let hosts = [
    {
        Hoyt_messaging.Host_manager.Host_entry.host_id=1l;
        service_id=1l;
        sub_socket="tcp://localhost:5001";
        push_socket="tcp://localhost:5002";
    };
    {
        host_id=2l;
        service_id=2l;
        sub_socket="tcp://localhost:5003";
        push_socket="tcp://localhost:5004";
    }
]

let () =
    let module H_m = Hoyt_messaging.Host_manager in 
    let module H_c = Hoyt_messaging.Connection_manager in
    let manager = H_m.make 1l in 
    let manager = H_m.load manager hosts in
    let ctx = Zmq.Context.create () in
    let connections = H_c.make ctx manager in
    Lwt_main.run
        (H_c.send_msg connections 1l "h" "m"
        >>= (fun _ -> print_endline "Message sent..."; 
            ignore (Hoyt_messaging.Connection_manager.terminate connections: bool);
            Zmq.Context.terminate ctx;
            Lwt.return_unit));
    ()