open Core

(* The type for the service identifier *)
type service_id = int32
(* The type for the host id. *)
type host_id = int32

(* The entry for a service.*)
module Host_entry = struct
    (* The entry for a host. *)
    type t = {
        (* The url for subscribing to events and let every subscriber know it's alive. *)
        sub_socket: string;
        (* The url for the push socket for sending rpc requests to. Heartbeat pings go over the subsocket and the subsocket should automatically send out heartbeats to let the services know it's active.*)
        push_socket: string;
    }
end 

module Service_entry = struct
    type t = {
        service_id: int32;
        hosts: Host_entry.t list;
    }
end

(* Represents the service entries. *)
type t = {

    host_id: host_id;
    (* The list of services in a cluster we can try to conenct to. *)
    services: (service_id,  Service_entry.t) Hashtbl.t;
    (* The lookup for a service by the host id.  Each service endpoint has a unique host id. *)
    hosts: (int32, Host_entry.t) Hashtbl.t;
}

let make host_id =
    {
        host_id;
        services=Hashtbl.create (module Int32);
        hosts=Hashtbl.create (module Int32);
    }

let get_service_id t service_id =
    Hashtbl.find t.services service_id