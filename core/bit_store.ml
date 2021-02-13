(* Decided to not use core here and the native library. *)
let shift = 6
let pos_mask = 63L

type t = {
  mask: int64;
  bits: int64;
  bitsI: int;
  length: int;
  size: int;
  sizeL: int64;
  values: (int64, Bigarray.int64_elt, Bigarray.c_layout) Bigarray.Array1.t;
}

let make size bits =
  (* Create the mask based on the number of bits. *)
  let mask = Int64.sub (Int64.shift_left 1L bits) 1L in
  let bits = Int64.of_int bits in
  let total_bits = Int64.mul bits size in
  let total_size = Int64.div total_bits 64L in
  (* If the value gets cut off we need on more long to cover the span. *)
  let reminder = Int64.logand pos_mask total_bits in
  let length = (if reminder > 0L then
    Int64.add total_size  1L
  else
    total_size)
  |> Int64.to_int
  in
  let values = Bigarray.Array1.create Bigarray.Int64 Bigarray.c_layout length in
  {
    mask;
    bits;
    bitsI=Int64.to_int bits;
    length;
    size=Int64.to_int size;
    sizeL=size;
    values;
  }

let length t =
  t.length

let start t pos =
  (* We need to calculate the starting position of the record value. *)
  let bit_pos = Int64.mul t.bits pos in
  (* Now shift the value to get the position based on a long. *)
  let the_start = Int64.shift_right_logical bit_pos shift 
    |> Int64.to_int in
  (* Get the reminder from the bit_pos since that will let us know if there is enough space. *)
  let reminder = Int64.logand bit_pos pos_mask 
    |> Int64.to_int in
  (the_start, reminder)

let end_ t start reminder =
  (* The stop position in the value.  If it overflows it will be greater than 64 and it will set that bit.*)
  let stop_position = reminder + t.bitsI in
  (* The left over bits at that position. *)
  let reminder = Int.logand stop_position 63 in
  (* A trick to get if we need to add 1 to the postion.*)
  let end_position = start + Int.shift_right_logical stop_position 6 in
  (end_position, reminder)

let read t pos =
  (assert (pos < t.sizeL));
  let module A = Bigarray.Array1 in
  let (start, remainder) = start t pos in
  (* Create the maks for the value for the first value. *)
  let value_mask = Int64.shift_left t.mask remainder in
  (* Get the value to read in. *)
  let value = Bigarray.Array1.get t.values start in
  (* Get the bytes that have been set. *)
  let value = Int64.logand value value_mask in
  (* Shift so we get the value. *)
  let value = Int64.shift_right_logical value remainder in

  (* Now get the end of the value. *)
  let (end_, shfit_bits) = end_ t start remainder in
  if start = end_ then
    value
  else 
    (* Now we need to get the mask for the reminder. If the remainder is 0 the value mask is zero.
    All the other operations below will not do anything due to it being 0. *)
    let value_mask = Int64.shift_left 1L shfit_bits in
    let value_mask = Int64.sub value_mask 1L in
    (* Get the end value.*)
    let end_value = A.get t.values end_ in
    (* We got the last part of the value. *)
    let end_value = Int64.logand end_value value_mask in
    (* Now we need to get the number of bytes to shift.*)
    let shift = t.bitsI - shfit_bits in
    (* now we have the higher order bit. *)
    let end_value = Int64.shift_left end_value shift in
    Int64.logor end_value value

let read_opt t pos =
  if pos < t.sizeL then
    read t pos |> Some
  else
    None

let write t pos new_value =
  (assert (pos < t.sizeL));
  let module A = Bigarray.Array1 in
  (* Get the positions we need to write to. *)
  let (start, reminder) = start t pos in
  (* Create the mask.  If it runs off we will handle it later. *)
  let mask = Int64.shift_left t.mask reminder in
  (* Zero out the position.  Minus one will be all 1s. *)
  let zero = Int64.logxor Int64.minus_one mask in
  (* Used to get the value at a positioo. *)
  let old_value = A.get t.values start in
  (* Shift the value to the new position. *)
  let new_updated = Int64.shift_left new_value reminder in
  (* Zero out the position.  *)
  let old_value = Int64.logand zero old_value in
  (* Update the value with the new one at that position. *)
  let new_updated = Int64.logor new_updated old_value in
  (* The the value. *)
  A.set t.values start new_updated;
  (* Figure out the end position. *)
  let (end_, shift_bits) = end_ t start reminder in
  if start = end_ then
    ()
  else
    (* Get the number of bits we need to shfit to. *)
    let fix = t.bitsI - shift_bits in
    (* Create a new mask for the front part of the position. *)
    let newMask = Int64.shift_left 1L fix in
    (* Need to subtract 1 to get the 1s we need at that positio. *)
    let newMask = Int64.sub newMask 1L in
    (* Create the amsk to zero out the position. *)
    let zero_position = Int64.logxor Int64.minus_one newMask in
    (* Get the old value we need to update.  *)
    let old_value = A.get t.values end_ in
    (* Shft the bits to the right of the hnew value to only expose the ones we want to overwrite. *)
    let new_updated = Int64.shift_right new_value fix in
    (* And it wil the zero value to 0 out the position we are about to update. *)
    let old_value = Int64.logand old_value zero_position in
    (* Create the new value with the logical or. *)
    let new_updated = Int64.logor old_value new_updated in
    (* Now we have the value so update it. *)
    A.set t.values end_ new_updated;
    ()

(** Calculates the middle for a binary search. 
@param start The starting index.
@param end The ending index. *)
let calculate_middle start end_ =
  let range = Int64.sub end_ start in
  let middle = Int64.div range 2L in
  Int64.add middle start

let binary_search t value increments =
  let search_length = Int64.div t.sizeL increments in
  let rec search start_idx end_idx pos =
    let current_value = read t (Int64.mul pos increments) in
    if value > current_value then
      (* We know at that position the value isn't there so add 1.*)
      let start_idx = Int64.add pos 1L in
      let pos = calculate_middle start_idx end_idx in
      (* Check to see if we we are done search. *)
      if pos >= end_idx then 
        pos
      else
        search start_idx end_idx pos
    else if value < current_value then
      (* We know the value isn't at that position so we can subtract 1 off of the end.*)
      let end_idx = Int64.sub pos 1L in
      let pos = calculate_middle start_idx end_idx in
      (* Check to see if the position is equal are less than.  Then we didn't find the value. *)
      if pos <= start_idx then
        pos
      else
        search start_idx end_idx pos
    else
      (* Values is equal to so we need to use it at the end. *)
      let end_idx = pos in
      let pos = calculate_middle start_idx end_idx in
      if pos >= end_idx then
        pos
      else 
        search start_idx end_idx pos
      in
  (* Calcualte the ending idx. *)
  let end_idx = (Int64.sub search_length 1L) in
  (* Now perform the binary search. *)
  let result_idx = search 0L (Int64.sub search_length 1L) (calculate_middle 0L end_idx) in
  let value_idx = Int64.mul result_idx increments in
  let result_value = read t value_idx in
  if result_value = value then
    Some value_idx
  else 
    None

let clone t new_size =
  let bit_store = make t.bits new_size in
  let rec copy_values pos =
    if pos < t.sizeL then
      let value = read t pos in
      write bit_store pos value;
      copy_values (Int64.add pos 1L)
    else
      ()
    in
  copy_values 0L;
  bit_store
