open! Core
module Test_connection_manager = Config.Test_connection_manager

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


module Router_info = struct 
  include Config.Connection_common

  let get_service_id (header: header) =
      header.toId

  let get_user_id (header: header) =
      header.userId

end

module Router_test = Hoyt_messaging.Router.Make_Service_router(Router_info)

module Test_processor = struct
  include Config.Connection_common
  type t = unit

  let handle_message header body =
      let header = {
          header with 
          Message.Header.messageType = Message.Header.MessageType.REPLY} in
      let header = Message.Header.to_proto header in
      Lwt.return (Ocaml_protoc_plugin.Writer.contents header, body)

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
        connections
     in 
    Lwt_main.run @@
        Router_test.listen router
        


