open Core
open HoytCore.State_machine
open Lwt.Infix

module Test_machine = struct

    type context = {
        ran: bool;
        action: bool
    }

    let make = 
        {
            ran = false;
            action = false;
        }

    type event =
        | Event1
        | Event2
        | Event3
        [@@deriving sexp_of, compare]

    type state =
        | StateA 
        | StateB 
        | StateC 
        [@@deriving sexp_of, compare]

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

    let what_action state event =
        match state with 
        | StateA -> (match event with 
            | Event1 -> Change_state StateB
            | Event2 -> Ignore
            | Event3 -> Action (fun ctx _ -> Lwt.return {
                ctx with action = true
            }))
        | StateB -> Action (fun ctx _ -> Lwt.return ctx)
        | StateC -> Ignore
        
    let state_change change_type ctx evt =
        match (change_type, evt) with 
        | (Entry StateA, Event1) -> Lwt.return ctx
        | (Entry StateA, Event2) -> Lwt.return ctx
        | (Entry StateA, Event3) -> Lwt.return ctx
        | (Exit StateA, _) -> Lwt.return ctx

        | (Entry StateB, Event1) -> 
            Lwt.return { ctx with
                ran = true
            }
        | (Entry StateB, _) -> Lwt.return ctx
        | (Exit StateB, _) -> Lwt.return ctx

        | (Entry StateC, _) -> Lwt.return ctx
        | (Exit StateC, _) -> Lwt.return ctx

end

module MyStateMachine = Make_persisted(Test_machine)

let%test_unit "Test state machine" =
    let context = Test_machine.make in
    [%test_eq: bool] false context.ran;
    let machine = MyStateMachine.make StateA context in 
    MyStateMachine.send machine Event1 >>= (fun ctx -> 
        Lwt.return @@ [%test_eq: bool] true ctx.ran)
        >>= (fun _ -> 
            let state = MyStateMachine.get_state machine in
            [%test_eq: Test_machine.state] StateB state;
            Lwt.return true)
        |> Lwt.ignore_result

let%test_unit "Test state machine ignore" =
    let context = Test_machine.make in
    [%test_eq: bool] false context.ran;
    let machine = MyStateMachine.make StateA context in 
    MyStateMachine.send machine Event2 >>= (fun ctx -> 
        Lwt.return @@ [%test_eq: bool] false ctx.ran)
        >>= (fun _ ->
            let state = MyStateMachine.get_state machine in
            [%test_eq: Test_machine.state] StateA state;
            Lwt.return_unit)
        |> Lwt.ignore_result

let%test_unit "Test state machine ignore" =
    let context = Test_machine.make in
    [%test_eq: bool] false context.ran;
    let machine = MyStateMachine.make StateA context in 
    MyStateMachine.send machine Event3 >>= (fun ctx -> 
        Lwt.return @@ [%test_eq: bool] true ctx.action;
    )
    |> Lwt.ignore_result