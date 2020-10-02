open Core

(* The type for the service identifier *)
type serviceId = int32
type hostId = int32

(* The entry for a host. *)
type rpcEntry = {
    pusSocket: string;
}

(* An entry for a subscription. *)
type subscribeEntry = {
    subSocket: string;
    pushSocket: string;
}

(* Represents a host entry.*)
type hostEntry =
    (* Reprsents a rpc entry. *)
    | Rpc of rpcEntry
    (* The host you can subscribe. *)
    | Subscription of subscribeEntry

(* Represents the service entries. *)
type serviceEntry = {
    (* The id of the service the entry is for. *)
    serviceId: int32;
    (* The list of hosts for the service. *)
    hosts: hostEntry list;
}

type t = {
    serverId: serviceId;
    services: (serviceId,  serviceEntry) Hashtbl.t;
    hosts: (int32, hostEntry) Hashtbl.t;
}

let make serverId =
    {
        serverId;
        services=Hashtbl.create (module Int32);
        hosts=Hashtbl.create (module Int32);
    }