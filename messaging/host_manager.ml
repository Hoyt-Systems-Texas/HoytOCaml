open Core

(* The type for the service identifier *)
type service_id = int32
(* The type for the host id. *)
type host_id = int32

(* The entry for a service.*)
module Host_entry = struct
    (* The entry for a host. *)
    type t = {
        (* The id of the service. *)
        service_id: int32 option;
        (* The name of the service. *)
        name: string;
        (* The id of the host. *)
        host_id: int32;
        (* The url for subscribing to events and let every subscriber know it's alive. *)
        sub_socket: string;
        (* The url for the push socket for sending rpc requests to. Heartbeat pings go over the subsocket and the subsocket should automatically send out heartbeats to let the services know it's active.*)
        push_socket: string;
        (* The address of the pull socket to send replies too. *)
        pull_socket: string;
    }
end 

module Service_entry = struct
    type t = {
        service_id: int32;
        hosts: Host_entry.t list;
    }
end

module Router_entry = struct
    type t = {
        router_id: int32;
        name: string;
        push_socket: string;
    }
end

(* Represents the service entries. *)
type t = {

    host_id: host_id;
    (* The list of services in a cluster we can try to conenct to. *)
    services: (service_id,  Service_entry.t) Hashtbl.t;
    (* The lookup for a service by the host id.  Each service endpoint has a unique host id. *)
    hosts: (int32, Host_entry.t) Hashtbl.t;
    (* The list of the routers to use. *)
    routers: (int32, Router_entry.t) Hashtbl.t;
}

let make host_id =
    {
        host_id;
        services=Hashtbl.create (module Int32);
        hosts=Hashtbl.create (module Int32);
        routers=Hashtbl.create (module Int32);
    }

let get_service_id t service_id =
    Hashtbl.find t.services service_id

let get_host t host_id =
    Hashtbl.find t.hosts host_id

let get_routers t =
    Hashtbl.data t.routers

let load t (hosts: Host_entry.t list) =
    let t = List.fold hosts ~init:t ~f:(fun t host ->
        match Hashtbl.add t.hosts ~key:host.host_id ~data:host with 
        | `Ok -> 
            t
        | `Duplicate ->
            Lwt_log.info ("Duplicate host entry " ^ Int32.to_string host.host_id)
            |> Lwt.ignore_result;
            t) in
    List.fold hosts ~init:t ~f:(fun t host ->
        match host.service_id with 
        | Some service_id -> 
            (match Hashtbl.add t.services ~key:service_id ~data: {
                service_id=service_id;
                hosts=[host]
            } with 
            | `Ok -> 
                t
            | `Duplicate ->
                Hashtbl.update t.services service_id ~f:(fun services ->
                    match services with
                    | Some s -> 
                        let hosts = host :: s.hosts in
                        {s with hosts=hosts}
                    | None ->
                        {
                            service_id=service_id;
                            hosts=[host];
                        });
                t)
        | None -> t)

let load_router t entries =
    List.fold entries ~init:t ~f:(fun t router -> 
        match Hashtbl.add t.routers ~key:router.Router_entry.router_id ~data:router with
        | `Ok -> 
            t
        | `Duplicate ->
            Lwt_log.info ("Duplicate router entry " ^ Int32.to_string router.router_id)
            |> Lwt.ignore_result;
            t)

let is_web host_id =
    Int32.is_negative host_id