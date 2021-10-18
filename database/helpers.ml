open! Core
open Lwt.Infix

let (>>=?) m f =
  m >>= (function | Ok x -> f x | Error err -> Lwt.return (Error err))

let empty_string value =
  if String.length value = 0 then
    None
  else
    Some value

let to_string value =
  match value with
  | Some value -> value
  | None -> ""

let empty_int64 id =
  if Int64.equal id 0L then
    None
  else
    Some id

let to_int64 id =
  match id with
  | Some id -> id
  | None -> 0L

(** Used to convert an int64 to a Ptime.t*)
let to_date date_mill =
  let date_mill = Int64.to_float date_mill in
  Ptime.of_float_s @@ date_mill /. 1000.0

(** Used to get the value from a date. *)
let from_date date =
  (Ptime.to_float_s date) *. 1000.0
  |> Float.to_int64

let log_error lwt_result =
  lwt_result >>= (function
    | Ok _ -> lwt_result
    | Error err ->
      let error = Caqti_error.show err in
      Logs.info (fun m -> m "%s" error);
      lwt_result)