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

    let get_respond_host_id _ =
        1l
end

module Test_connection_manager = Hoyt_messaging.Connection_manager.Make_connections(Test_connection_info)

let router = [
    {
        Hoyt_messaging.Host_manager.Router_entry.router_id = 1l;
        name="test Router";
        push_socket="tcp://localhost:4000"
    }
]