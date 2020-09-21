type error =
    | Required
    | MinLength of int
    | MaxLength of int

type errors = error list

module StringValidation : sig

    type t = {
        required: bool;
        minLength: int;
        maxLength: int;
    }

    val validation : t -> string -> errors
end
(*
module IntValidation : sig
    type t = {
        fieldName: string;
        required: bool;
        minValue: int32;
        maxValue: int32;
    }

    val validation : t -> int32 -> errors
end
*)