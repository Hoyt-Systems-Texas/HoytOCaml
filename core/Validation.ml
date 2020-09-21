type error =
    | Required
    | MinLength of int
    | MaxLength of int

type errors = error list

module StringValidation = struct
  type t = {
      required: bool;
      minLength: int;
      maxLength: int;
  }

  let validation t value =
    let v = String.trim value in
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