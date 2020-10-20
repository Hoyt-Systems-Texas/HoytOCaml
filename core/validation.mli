type error =
  | Required
  | Min_length of int
  | Max_length of int
  | Min_value of int
  | Max_value of int
  [@@deriving sexp_of, compare]

type errors = error list

module String_validation : sig

  type t = {
    required: bool;
    min_length: int;
    max_length: int;
  } [@@deriving sexp_of, compare]

  val validation : t -> string -> errors
end

module Int_validation : sig
  type t = {
    min_value: int;
    max_value: int;
  } [@@deriving sexp_of, compare]

  val validation : t -> int -> errors
end