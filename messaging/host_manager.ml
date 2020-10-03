open Core

(* The type for the service identifier *)
type service_id = int32
type host_id = int32

module Rpc_entry = struct
    (* The entry for a host. *)
    type t = {
        push_socket: string;
    }
end 

module Subscribe_entry = struct
    (* An entry for a subscription. *)
    type t = {
        sub_socket: string;
        push_socket: string;
    }
end

module Host_entry = struct
    (* Represents a host entry.*)
    type t =
        (* Reprsents a rpc entry. *)
        | Rpc of Rpc_entry.t
        (* The host you can subscribe. *)
        | Subscription of Subscribe_entry.t
end

module Service_entry = struct

    type t = {
        (* The id of the service the entry is for. *)
        service_id: int32;
        (* The list of hosts for the service. *)
        hosts: Host_entry.t list;
    }
end

(* Represents the service entries. *)
type t = {
    server_id: service_id;
    services: (service_id,  Service_entry.t) Hashtbl.t;
    hosts: (int32, Host_entry.t) Hashtbl.t;
}

let make server_id =
    {
        server_id;
        services=Hashtbl.create (module Int32);
        hosts=Hashtbl.create (module Int32);
    }

let get_service_id t service_id =
    Hashtbl.find t.services service_id