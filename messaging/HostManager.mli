(*
    Used to manage the location of hosts.  The goal is to have a really fast lookup and based on zero mq.
*)
type t
(* The type for the service id. *)
type serviceId = int32
(* The host id. *)
type hostId = int32

module RpcEntry : sig
    (* The entry for a host. *)
    type t = {
        pusSocket: string;
    }
end

module SubscribeEntry : sig

    (* An entry for a subscription. *)
    type t = {
        (* The location for the subscribtion in a socket.*)
        subSocket: string;
        (* The push socket for to send heartbeat request to. *)
        pushSocket: string;
    }

end

module HostEntry : sig
    (* Represents a host entry.*)
    type t =
        (* Reprsents a rpc entry. *)
        | Rpc of RpcEntry.t
        (* The host you can subscribe. *)
        | Subscription of SubscribeEntry.t
end

module ServiceEntry : sig

    (* Represents the service entries. *)
    type t = {
        (* The id of the service the entry is for. *)
        serviceId: int32;
        (* The list of hosts for the service. *)
        hosts: HostEntry.t list;
    }

end

(* Used to make a new collection. *)
val make : hostId -> t

(* Gets the id of the service. *)
val getServiceId : t -> serviceId -> ServiceEntry.t option