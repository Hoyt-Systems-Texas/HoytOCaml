module type Publisher_type = sig
  include Common.Common_processor
end

module Make_message_publish(P: Publisher_type) : sig
  type t

  val make: P.connection_manager -> Zmq.Context.t -> string -> t
  (** Creates a new publisher. *)

  val bind: t -> unit

  val notify: t -> P.header -> P.encoding -> unit Lwt.t
  (** Broadcasts a message to the listenting services. *)

end