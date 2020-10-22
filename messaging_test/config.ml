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

module Connection_common = struct
  type encoding = string
  type header = Message.Header.t
  type connection_manager = Test_connection_manager.t

  let encode_header h =
    Message.Header.to_proto h
    |> Ocaml_protoc_plugin.Writer.contents
    
  let decode_header b = 
      let result = Ocaml_protoc_plugin.Reader.create b in 
      match Message.Header.from_proto result with
      | Ok h -> Some h
      | Error(_) -> None

  let from_id (h:header) = h.fromId

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

  let set_message_type (header: header) message_type =
    let module H_M_T = Hoyt_messaging.Messaging.Message_type in
    let module M_H_T = Message.Header.MessageType in
    let ms_type = match message_type with
    | H_M_T.Ping -> M_H_T.PING
    | H_M_T.Pong -> M_H_T.PONG
    | H_M_T.Status -> M_H_T.STATUS
    | H_M_T.Req -> M_H_T.REQ
    | H_M_T.Reply -> M_H_T.REPLY
    | H_M_T.Event -> M_H_T.EVENT in
    {
      header with
      messageType = ms_type
    }

  let send_msg = Test_connection_manager.routable_message
  
end