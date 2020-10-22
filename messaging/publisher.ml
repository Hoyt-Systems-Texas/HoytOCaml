module type Publisher_type = sig
  include Common.Common_processor
end

module Make_message_publish(P: Publisher_type) = struct
  type t = {
    connection_manager: P.connection_manager;
    context: Zmq.Context.t;
    socket: [`Pub] Zmq.Socket.t;
    binding_url: string;
  }

  let make con ctx binding_url =
    let socket = Zmq.Socket.create ctx Zmq.Socket.pub in
    {
      connection_manager=con;
      context=ctx;
      socket;
      binding_url
    }

  let bind t =
    Zmq.Socket.bind t.socket t.binding_url

  let notify _ _ _ = Lwt.return_unit
  
end