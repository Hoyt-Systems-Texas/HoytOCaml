open! Core
open Lwt.Infix

module type Connection_info = sig
    type header
    
    val deserialize_header : string -> header option

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

    let send t push_socket corr_id header body =
        let (def, resolver) = Lwt.wait () in
        ignore (Hashtbl.add t.pending_messages ~key:corr_id ~data:{
            Pending_message.correlation_id=corr_id;
            time=Time.now ();
            deferred=resolver;
        }: [`Duplicate | `Ok]);
        Zmq.Socket.send push_socket header ~more:true;
        Zmq.Socket.send push_socket body;
        def

    let next_id t =
        let corr_id = !(t.correlation_id) in 
        (t.correlation_id) := Int64.(+) corr_id 1L;
        corr_id

    let send_msg t host_id corr_id header body =
        match Hashtbl.find t.push_sockets host_id with
        | Some conn ->
            send t conn.push_socket corr_id header body
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
                    send t conn.push_socket corr_id header body
                | `Duplicate -> 
                    Lwt_log.info "Had a duplicate when adding a connection.  This should never happen."
                    |> Lwt.ignore_result;
                    Lwt.return Messaging.Pending_message.Full)
            | None ->
                Lwt.return Messaging.Pending_message.Full)

    (*
    let send_reply t host_id correlation_id header body =
        Lwt.return_unit
        *)

    let terminate t =
        Hashtbl.for_all t.push_sockets ~f:(fun b ->
            Socket_entry.close b;
            true)

    let resolve t h m =
        match M.deserialize_header h with
        | Some header -> (
            let corr_id = M.get_correlation_id header in
            match Hashtbl.find_and_remove t.pending_messages corr_id with
            | Some r -> 
                Lwt.wakeup r.deferred (Messaging.Pending_message.Message (header, m));
                Lwt.return_unit
            | None -> Lwt.return_unit)
        | None -> Lwt.return_unit

    let start_loop t =
        let pull_socket = Zmq.Socket.create t.context Zmq.Socket.pull in
        let pull_socket_lwt = Zmq_lwt.Socket.of_socket pull_socket in 
        Zmq.Socket.bind pull_socket t.reply_socket;
        let rec loop_rec () =
            Zmq_lwt.Socket.recv pull_socket_lwt
            >>= fun h -> 
                match Zmq.Socket.has_more pull_socket with
                | true ->
                    Zmq_lwt.Socket.recv pull_socket_lwt
                    >>= (fun m -> resolve t h m)
                | false -> Lwt.return_unit
            >>= fun _ -> (loop_rec [@tailcall]) () in 
        loop_rec ()

end