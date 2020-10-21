open! Core
open Pow

type 'a record = 
  | Empty
  | Value of 'a

type 'a t = {
  buffer: 'a record Array.t;
  current_pos: int64 ref;
  mask: int64;
  size: int32;
  size_64: int64;
}

let make num start_num =
  match to_power_of_2 num with
  | Some size ->
    let size_64 = Int32.to_int64 num in
    let mask = Int64.(-) size_64 1L in
    Some {
      buffer=Array.create ~len:(Int32.to_int_exn size) Empty;
      current_pos=ref start_num;
      mask;
      size;
      size_64;
    }
  | None -> None

let min_index t =
  Int64.(-) !(t.current_pos) t.size_64
  |> Int64.(+) 1L
(** Calculates the minimum postion you can get the value from. *)
    
let calc_pos t pos =
  let p = Int64.bit_and t.mask pos in
  Int64.to_int_exn p

let get t p =
  if Int64.(<) p (min_index t) then
    None
  else
    let pos =  calc_pos t p in
    match Array.get t.buffer pos with
      | Empty -> None
      | Value a -> Some a

let add t p =
  let current_pos = t.current_pos in
  let next_pos = Int64.(+) !current_pos 1L in
  let a_pos = calc_pos t next_pos in 
  Array.set t.buffer a_pos (Value p);
  current_pos := next_pos;
  next_pos

let size t =
  t.size