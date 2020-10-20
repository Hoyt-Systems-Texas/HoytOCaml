open Core

type error =
  | Required
  | Min_length of int
  | Max_length of int
  | Min_value of int
  | Max_value of int
  [@@deriving sexp_of,compare]

type errors = error list

module String_validation = struct
  type t = {
    required: bool;
    min_length: int;
    max_length: int;
  }  [@@deriving sexp_of, compare]

  let validation t value =
    let v = String.strip value in
    let length = String.length v in
    if t.required && length = 0 then
      [Required]
    else
      let errors = 
        if t.min_length > length then 
          [Min_length t.min_length]
        else
          []
        in 
      if t.max_length < length then
        Max_length t.max_length::errors
      else
        errors
end

module Int_validation = struct
  type t = {
    min_value: int;
    max_value: int;
  }  [@@deriving sexp_of, compare]

  let validation t v =
    let errors = if t.min_value > v then
      [Min_value t.min_value]
    else
      [] in
    if t.max_value < v then
      Max_value t.max_value::errors
    else
      errors
end