open Core
open Lwt.Infix

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

module Make_persisted(M: State_machine) = struct

  type run_state = 
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
    queue: request Skip_queue.t;
    active_state: run_state ref;
  }

  let make state ctx = 
    {
      state = ref state;
      ctx = ref ctx;
      queue = Skip_queue.make ();
      active_state = ref Idle;
    }

  let handleEvent t event resolve =
    match M.what_action !(t.state) event with
    | Defer -> Skip_queue.defer t.queue {event; resolve}
    | Change_state state -> 
      let current_state = !(t.state) in
      let ctx = !(t.ctx) in
      let result = M.state_change (M.Exit current_state) ctx event in 
      result >>= (fun ctx -> 
        let ctxRef = t.ctx in
        ctxRef := ctx;
        M.state_change (M.Entry state) ctx event)
      >>= (fun ctx ->
        Skip_queue.reset t.queue;
        let s = t.state in s := state;
        let c = t.ctx in c := ctx;
        Lwt.wakeup resolve ctx;
        Lwt.return ctx)
      |> Lwt.ignore_result
    | Action act ->
      act !(t.ctx) event >>= (fun ctx ->
        let c = t.ctx in c := ctx;
        Lwt.return ctx)
        >>= (fun ctx ->
          Lwt.wakeup resolve ctx;
          Lwt.return_unit)
        |> Lwt.ignore_result
    | Ignore ->
      Lwt.wakeup resolve !(t.ctx);
      ()


  let eventLoop t =
    if compare_run_state !(t.active_state) Idle = 0 then
      let s = t.active_state in s := Running;
      let rec loop _ =
        match Skip_queue.dequeue t.queue with
        | Some{event; resolve} ->
          handleEvent t event resolve;
          loop ();
        | None -> 
          let s = t.active_state in s := Idle;
          ()
        in loop ()
    else 
        ()

  let send t event =
    let (promise, resolve) = Lwt.wait () in
    Skip_queue.enqueue t.queue {
      event; 
      resolve;
    };
    eventLoop t;
    promise

  let get_ctx t =
    !(t.ctx)

  let get_state t =
    !(t.state)

end