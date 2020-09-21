open Core
open HoytCore.Validation

let%test_unit "Test Required Missing" =
    let v = {
        StringValidation.required = true;
        minLength = 0;
        maxLength = 100
    } in
    let errors = StringValidation.validation v "" in
    [%test_eq: error list] [Required] errors

let%test_unit "Test required true" =
    let v = {
        StringValidation.required = true;
        minLength = 0;
        maxLength = 100
    } in
    let errors = StringValidation.validation v "hi" in
    [%test_eq: error list] [] errors

let%test_unit "Min length test" =
    let v = {
        StringValidation.required = true;
        minLength = 2;
        maxLength = 3;
    } in
    let errors = StringValidation.validation v "a" in
    [%test_eq: error list] [MinLength(2)] errors

let%test_unit "Max length test" =
    let v = {
        StringValidation.required = true;
        minLength = 0;
        maxLength = 10;
    } in
    let errors = StringValidation.validation v "12345678901" in
    [%test_eq: error list] [MaxLength(10)] errors