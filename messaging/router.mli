module type Service_router_info = sig

    include Common.Common_processor

    val get_service_id: header -> int32
    (** The id of the service to send the message to. *)

    val get_user_id: header -> int64
    (** Gets the id of the user who is making the request. *)

end

module Make_Service_router(I: Service_router_info) : sig

    type t

    val make : Zmq.Context.t ->
        string ->
        Host_manager.t ->
        I.connection_manager ->
        t
    (** Creates a new router.
      Arguments:
      ctx - The zmq context to use to create the conenctions.
      bind_address - The binding address for the socket.
      host_manager - The host manager.
     *)

    val listen : t -> unit Lwt.t
    (** Starts the main listener to forward the messages. *)
end