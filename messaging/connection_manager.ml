open! Core

module type Connection_info = sig
    type header
    
    val get_correlation_id : header -> int64

    val get_respond_host_id : header -> int32
end

module Socket_entry = struct
    type t = {
        host_id: Host_manager.host_id;
        push_socket: [`Push] Zmq.Socket.t;
        (* The last we tried to send a message to host. *)
        last_used: Core.Time.t;
    }

    let close t = 
        Zmq.Socket.close t.push_socket
end

module Pending_message = struct
    type 'a t = {
        correlation_id: int64;
        time: Time.t;
        deferred: 'a Messaging.Pending_message.t Lwt.u;
    }

end

module Make_connections(M: Connection_info) = struct

    type t = {
        (* The correlation id of the host. *)
        correlation_id: int64 ref;
        (* The storage of the push sockets. *)
        push_sockets: (Host_manager.host_id, Socket_entry.t) Hashtbl.t;
        (* The host manager. *)
        host_manager: Host_manager.t;
        (* The zeromq context for creating the sockets. *)
        context: Zmq.Context.t;
        (* The address for the reply sockets. *)
        reply_socket: string;
        (* The pending messages to be sent back. *)
        pending_messages: (int64, M.header Pending_message.t) Hashtbl.t;
    }

    let make ctx host_manager reply_socket =
        let push_sockets = Hashtbl.create (module Int32) in
        let pending_messages = Hashtbl.create (module Int64) in
        {
            context=ctx;
            correlation_id=ref 0L;
            push_sockets;
            host_manager;
            reply_socket;
            pending_messages;
        }

    let send_msg_int socket header body =
        Zmq.Socket.send socket header ~more:true;
        Zmq.Socket.send socket body;
        ()

    let send t push_socket corr_id header body =
        let (def, resolver) = Lwt.wait () in
        ignore (Hashtbl.add t.pending_messages ~key:corr_id ~data:{
            Pending_message.correlation_id=corr_id;
            time=Time.now ();
            deferred=resolver;
        }: [`Duplicate | `Ok]);
        send_msg_int push_socket header body;
        def

    let next_id t =
        let corr_id = !(t.correlation_id) in 
        (t.correlation_id) := Int64.(+) corr_id 1L;
        corr_id

    let get_socket t host_id =
        match Hashtbl.find t.push_sockets host_id with
        | Some conn -> Some conn
        | None ->
            (match Host_manager.get_host t.host_manager host_id with
            | Some host -> 
                let socket = Zmq.Socket.create t.context Zmq.Socket.push in
                Zmq.Socket.connect socket host.push_socket;
                let conn = {
                    Socket_entry.host_id=host_id;
                    push_socket=socket;
                    last_used=Core.Time.now ()
                } in (
                match Hashtbl.add t.push_sockets ~key:host_id ~data:conn with 
                | `Ok -> 
                    Some conn
                | `Duplicate -> 
                    Lwt_log.info "Had a duplicate when adding a connection.  This should never happen."
                    |> Lwt.ignore_result;
                    None)
            | None -> None)


    let send_msg t host_id corr_id header body =
        match get_socket t host_id with
        | Some conn ->
            send t conn.push_socket corr_id header body
        | None -> Lwt.return Messaging.Pending_message.Full

    let send_reply t host_id header body =
        match get_socket t host_id with
        | Some conn ->
            send_msg_int conn.push_socket header body;
            Lwt.return_unit
        | None ->
            Lwt.return_unit

    let terminate t =
        Hashtbl.for_all t.push_sockets ~f:(fun b ->
            Socket_entry.close b;
            true)

    let resolve t h m =
        let corr_id = M.get_correlation_id h in
        match Hashtbl.find_and_remove t.pending_messages corr_id with
        | Some r -> 
            Lwt.wakeup r.deferred (Messaging.Pending_message.Message (h, m));
            Lwt.return_unit
        | None -> Lwt.return_unit

end