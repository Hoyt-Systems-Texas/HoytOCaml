open Core

type error =
    | Required
    | MinLength of int
    | MaxLength of int
    | MinValue of int
    | MaxValue of int
    [@@deriving sexp_of,compare]

type errors = error list

module StringValidation = struct
    type t = {
        required: bool;
        minLength: int;
        maxLength: int;
    }  [@@deriving sexp_of, compare]

    let validation t value =
        let v = String.strip value in
        let length = String.length v in
        if t.required && length = 0 then
            [Required]
        else
            let errors = 
                if t.minLength > length then 
                    [MinLength t.minLength]
                else
                    []
                in 
            if t.maxLength < length then
                MaxLength t.maxLength::errors
            else
                errors
end

module IntValidation = struct
    type t = {
        minValue: int;
        maxValue: int;
    }  [@@deriving sexp_of, compare]

    let validation t v =
        let errors = if t.minValue > v then
            [MinValue t.minValue]
        else
            [] in
        if t.maxValue < v then
            MaxValue t.maxValue::errors
        else
            errors
end