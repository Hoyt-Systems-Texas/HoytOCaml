module type Subscriber_info = sig

  include Common.Common_processor

  val ping : int64 -> encoding
  (** Creates a message for send a ping. *)

  val handle_message : header -> encoding -> unit Lwt.t
  (** The handler for the incoming message. *)

end

(** Used to create something to handle a subscriber.*)
module Make_Subscriber_info_zeromq(S: Subscriber_info) : sig
  type t

  val make : Zmq.Context.t -> Host_manager.host_id -> Host_manager.service_id -> Host_manager.t -> t

  val listen : t -> unit Lwt.t
end