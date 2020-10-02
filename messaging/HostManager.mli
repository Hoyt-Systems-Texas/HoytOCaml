(*
    Used to manage the location of hosts.  The goal is to have a really fast lookup and based on zero mq.
*)
type t
(* The type for the service id. *)
type serviceId = int32
(* The host id. *)
type hostId = int32

(* The entry for a host. *)
type rpcEntry = {
    pusSocket: string;
}

(* An entry for a subscription. *)
type subscribeEntry = {
    (* The location for the subscribtion in a socket.*)
    subSocket: string;
    (* The push socket for to send heartbeat request to. *)
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

(* Used to make a new collection. *)
val make : hostId -> t