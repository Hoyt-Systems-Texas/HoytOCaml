type error =
    | Required
    | MinLength of int
    | MaxLength of int
    | MinValue of int
    | MaxValue of int
    [@@deriving sexp_of, compare]

type errors = error list

module StringValidation : sig

    type t = {
        required: bool;
        minLength: int;
        maxLength: int;
    }

    val validation : t -> string -> errors
end

module IntValidation : sig
    type t = {
        minValue: int;
        maxValue: int;
    }

    val validation : t -> int -> errors
end