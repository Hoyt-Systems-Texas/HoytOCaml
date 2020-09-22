module type StateMachine = sig
    type context
    type event
    type state


    type stateChangeType =
        | Entry of state
        | Exit of state


    type result =
        | Ran of context
        | Full
        | Deferred

    type stateAction =
        | Defer
        | ChangeState of state
        | Action of (context -> event -> context Lwt.t)
        | Ignore

    val whatAction : state -> event -> stateAction

    val stateChange : stateChangeType -> context -> event -> context Lwt.t

end

module Make_persisted(M: StateMachine) : sig

    type t

    val send : t -> M.event -> M.context Lwt.t

    val getCtx : t -> M.context

    val getState : t -> M.state

    val make : M.state -> M.context -> t

end