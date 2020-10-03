open Core

(* The type for the service identifier *)
type serviceId = int32
type hostId = int32

module RpcEntry = struct
    (* The entry for a host. *)
    type t = {
        pusSocket: string;
    }
end 

module SubscribeEntry = struct
    (* An entry for a subscription. *)
    type t = {
        subSocket: string;
        pushSocket: string;
    }
end

module HostEntry = struct
    (* Represents a host entry.*)
    type t =
        (* Reprsents a rpc entry. *)
        | Rpc of RpcEntry.t
        (* The host you can subscribe. *)
        | Subscription of SubscribeEntry.t
end

module ServiceEntry = struct

    type t = {
        (* The id of the service the entry is for. *)
        serviceId: int32;
        (* The list of hosts for the service. *)
        hosts: HostEntry.t list;
    }
end

(* Represents the service entries. *)
type t = {
    serverId: serviceId;
    services: (serviceId,  ServiceEntry.t) Hashtbl.t;
    hosts: (int32, HostEntry.t) Hashtbl.t;
}

let make serverId =
    {
        serverId;
        services=Hashtbl.create (module Int32);
        hosts=Hashtbl.create (module Int32);
    }

let getServiceId t serviceId =
    Hashtbl.find t.services serviceId