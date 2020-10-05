open! Core

type socket_entry = {
    host_id: Host_manager.host_id;
    push_socket: [`Push] Zmq.Socket.t;
    (* The last we tried to send a message to host. *)
    last_used: Core.Time.t;
}

type t = {
    (* The id of the host. *)
    host_id: Host_manager.host_id;
    (* The correlation id of the host. *)
    correlation_id: int64;
    (* The storage of the push sockets. *)
    push_sockets: (Host_manager.host_id, socket_entry) Hashtbl.t;
    (* The host manager. *)
    host_manager: Host_manager.t;
    context: Zmq.Context.t;
}

let make ctx host_id host_manager =
    let push_sockets = Hashtbl.create (module Int32) in
    {
        context=ctx;
        host_id;
        correlation_id=0L;
        push_sockets;
        host_manager;
    }

let send push_socket header body =
    Zmq.Socket.send push_socket header ~more:true;
    Zmq.Socket.send push_socket body;
    Lwt.return_unit

let send_msg t host_id header body =
    match Hashtbl.find t.push_sockets host_id with
    | Some conn ->
        send conn.push_socket header body
    | None -> 
        (match Host_manager.get_host t.host_manager host_id with 
        | Some host -> 
            let socket = Zmq.Socket.create t.context Zmq.Socket.push in
            Zmq.Socket.connect socket host.push_socket;
            let conn = {
                host_id;
                push_socket=socket;
                last_used=Core.Time.now ()
            } in (
            match Hashtbl.add t.push_sockets ~key:host_id ~data:conn with 
            | `Ok -> Lwt.return_unit
            | `Duplicate -> 
                Lwt_log.info "Had a duplicate when adding a connection.  This should never happen.")
        | None ->
            Lwt.return_unit)
