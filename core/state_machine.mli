module type State_machine = sig
  type context
  type event
  type state


  type state_change_type =
    | Entry of state
    | Exit of state


  type result =
    | Ran of context
    | Full
    | Deferred

  type state_action =
    | Defer
    | Change_state of state
    | Action of (context -> event -> context Lwt.t)
    | Ignore

  val what_action : state -> event -> state_action

  val state_change : state_change_type -> context -> event -> context Lwt.t

end

module Make_persisted(M: State_machine) : sig

  type t

  val send : t -> M.event -> M.context Lwt.t

  val get_ctx : t -> M.context

  val get_state : t -> M.state

  val make : M.state -> M.context -> t

end