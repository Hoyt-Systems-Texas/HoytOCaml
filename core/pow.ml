open! Core
let max_power = Int32.shift_left 1l 30
(** The maximum power of two.*)

let is_power_2 i =
  Int32.(-) i 1l
  |> Int32.bit_and i
  |> Int32.equal 0l

let next_power i =
  let num = (fun off i -> Int32.bit_or i @@ Int32.shift_right i off) in
  num 1 i
  |> num 2
  |> num 4
  |> num 8
  |> num 16
  |> (fun i -> Int32.(+) i 1l)

let to_power_of_2 i =
  if Int32.(>) i max_power then 
    None
  else if Int32.(<) i 0l then
    None
  else if is_power_2 i then
    Some(i)
  else
    Some(next_power i)