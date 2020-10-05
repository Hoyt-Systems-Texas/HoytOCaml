(*
    Used to manage the location of hosts.  The goal is to have a really fast lookup and based on zero mq.
*)
type t
(* The type for the service id. *)
type service_id = int32
(* The host id. *)
type host_id = int32

module Host_entry : sig

    (* An entry for a subscription. *)
    type t = {
        (* The id of the service. *)
        service_id: int32 option;
        (* The id of the host. *)
        host_id: int32;
        (* The location for the subscribtion in a socket.*)
        sub_socket: string;
        (* The push socket for to sending rpc and heartbeat request to. *)
        push_socket: string;
    }

end

module Service_entry : sig

    (* Represents the service entries. *)
    type t = {
        (* The id of the service the entry is for. *)
        service_id: int32;
        (* The list of hosts for the service. *)
        hosts: Host_entry.t list;
    }

end

(* Used to make a new collection. *)
val make : host_id -> t

(* Gets the id of the service. *)
val get_service_id : t -> service_id -> Service_entry.t option

(* Used to get a host with the specified id. *)
val get_host : t -> host_id -> Host_entry.t option

(* Used to load the hosts and sevices into a dictionary. *)
val load : t -> Host_entry.t list -> t