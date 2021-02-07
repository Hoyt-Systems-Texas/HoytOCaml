let shift = 6
let pos_mask = 63L

type t = {
  mask: int64;
  bits: int64;
  bitsI: int;
  length: int;
  size: int;
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
  (* This value will either be 1 or 0. *)
  let has_remainder = end_ - start in
  let has_remainder64 = Int64.of_int has_remainder in
  (* Now we need to get the mask for the reminder. If the remainder is 0 the value mask is zero.
  All the other operations below will not do anything due to it being 0. *)
  let value_mask = Int64.shift_left has_remainder64 shfit_bits in
  let value_mask = Int64.sub value_mask has_remainder64 in
  (* Get the end value.*)
  let end_value = A.get t.values end_ in
  (* We got the last part of the value. *)
  let end_value = Int64.logand end_value value_mask in
  (* Now we need to get the number of bytes to shift.*)
  let shift = t.bitsI - shfit_bits in
  (* now we have the higher order bit. *)
  let end_value = Int64.shift_left end_value shift in
  Int64.logor end_value value
