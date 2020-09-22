open Core

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

module Persisted(M: StateMachine) = struct

    type runState = 
        | Idle
        | Running
        [@@deriving sexp_of,compare]

    type request = {
        event: M.event;
        resolve: M.context Lwt.u;
    }

    type t = {
        state: M.state ref;
        ctx: M.context ref;
        queue: request Queue.t;
        activeState: runState ref;
    }

    let eventLoop t =
        if compare_runState !(t.activeState) Idle = 0 then
            let s = t.activeState in s := Running;
            let rec loop _ =
                match Queue.dequeue t.queue with
                | Some(_) ->
                    loop ()
                | None -> ()
                in 
                loop ()
        else 
            ()

    let send t event =
        let (promise, resolve) = Lwt.wait () in
        Queue.enqueue t.queue {
            event; 
            resolve;
        };
        eventLoop t;
        promise

    let getCtx t =
        !(t.ctx)

    let getState t =
        !(t.state)
end