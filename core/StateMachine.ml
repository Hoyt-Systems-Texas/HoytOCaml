open Core
open Lwt.Infix

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
        queue: request SkipQueue.t;
        activeState: runState ref;
    }

    let handleEvent t event resolve =
        match M.whatAction !(t.state) event with
        | Defer -> SkipQueue.defer t.queue {event; resolve}
        | ChangeState state -> 
            let currentState = !(t.state) in
            let ctx = !(t.ctx) in
            let result = M.stateChange (M.Entry currentState) ctx event in 
            result >>= (fun ctx -> 
                let ctxRef = t.ctx in
                ctxRef := ctx;
                M.stateChange (M.Exit state) ctx event)
            |> Lwt.ignore_result
        | Action _ ->
            ()
        | Ignore ->
            Lwt.wakeup resolve !(t.ctx);
            ()


    let eventLoop t =
        if compare_runState !(t.activeState) Idle = 0 then
            let s = t.activeState in s := Running;
            let rec loop _ =
                match SkipQueue.dequeue t.queue with
                | Some{event; resolve} ->
                    handleEvent t event resolve;
                    loop ();
                | None -> 
                    let s = t.activeState in s := Idle;
                    ()
                in loop ()
        else 
            ()

    let send t event =
        let (promise, resolve) = Lwt.wait () in
        SkipQueue.enqueue t.queue {
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