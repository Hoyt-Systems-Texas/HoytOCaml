open! Core
module Test_connection_manager = Config.Test_connection_manager

module Test_processor = struct
  include Config.Connection_common
  type t = string

  let handle_message header body =
      let header = {
          header with 
          Message.Header.messageType = Message.Header.MessageType.REPLY} in
      let header = Message.Header.to_proto header in
      Lwt.return (Ocaml_protoc_plugin.Writer.contents header, body)

  let resolve = Test_connection_manager.resolve
end

module Service_processor = Hoyt_messaging.Rpc.Make_Request_processor(Test_processor)

let hosts = [
    {
        Hoyt_messaging.Host_manager.Host_entry.host_id=1l;
        service_id=Some 1l;
        name="Test Service 1";
        sub_socket="tcp://localhost:5001";
        push_socket="tcp://localhost:5002";
        pull_socket="tcp://localhost:4000";
    };
    {
        host_id=2l;
        service_id=Some 2l;
        name="Test Service 2";
        sub_socket="tcp://localhost:5003";
        push_socket="tcp://localhost:5004";
        pull_socket="tcp://localhost:4001";
    };
    {
        host_id=(-1l);
        service_id=None;
        name="Web 1";
        sub_socket="tcp://localhost:3000";
        push_socket="tcp://localhost:3001";
        pull_socket="tcp://localhost:4002";
    };
]

let () =
    let ctx = Zmq.Context.create () in 
    let host_id = 1l in
    let service_id = 1l in 
    let bind_url = "tcp://*:5002" in 
    let module H_c = Test_connection_manager in
    let host_manager = Hosts_config.create_host_manager 1l in
    let connections = H_c.make ctx host_manager in
    let processor = Service_processor.make ctx 
        bind_url 
        host_id 
        service_id 
        host_manager 
        connections
        "" in
    Lwt_main.run @@ Service_processor.listen processor