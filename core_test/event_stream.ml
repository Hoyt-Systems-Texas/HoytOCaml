open! Core
open HoytCore.Event_stream

module Test_event_stream = struct
  type record = int
  let test_value = ref None

  let handler ~id:_ ~data =
    test_value := Some data

end

module My_stream = Make_event_stream(Test_event_stream)

let%test_unit "Queue test" =
  let stream = My_stream.make 12l in
  match stream with
  | Some _ -> ()
  | None -> failwith("Unable to make the event stream.")

let%test_unit "Enqueue test" =
  (Test_event_stream.test_value) := None;
  match My_stream.make 16l with
  | Some s ->
    My_stream.add s 1;
    [%test_eq: int option] !(Test_event_stream.test_value) (Some 1)
  | None ->
    failwith "Unable to make the event stream."