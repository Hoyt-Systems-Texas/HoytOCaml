open Core
open HoytCore.Validation

let%test_unit "Test Required Missing" =
    let v = {
        String_validation.required = true;
        min_length = 0;
        max_length = 100
    } in
    let errors = String_validation.validation v "" in
    [%test_eq: error list] [Required] errors

let%test_unit "Test required true" =
    let v = {
        String_validation.required = true;
        min_length = 0;
        max_length = 100
    } in
    let errors = String_validation.validation v "hi" in
    [%test_eq: error list] [] errors

let%test_unit "Min length test" =
    let v = {
        String_validation.required = true;
        min_length = 2;
        max_length = 3;
    } in
    let errors = String_validation.validation v "a" in
    [%test_eq: error list] [Min_length(2)] errors

let%test_unit "Max length test" =
    let v = {
        String_validation.required = true;
        min_length = 0;
        max_length = 10;
    } in
    let errors = String_validation.validation v "12345678901" in
    [%test_eq: error list] [Max_length(10)] errors

let%test_unit "Int min value test" =
    let v = {
        Int_validation.min_value = 1;
        max_value = 10;
    } in
    let errors = Int_validation.validation v 0 in
    [%test_eq: error list] [Min_value(1)] errors

let%test_unit "Int max value test" =
    let v = {
        Int_validation.min_value = 1;
        max_value = 10;
    } in
    let errors = Int_validation.validation v 11 in
    [%test_eq: error list] [Max_value(10)] errors

let%test_unit "Int correct test" =
    let v = {
        Int_validation.min_value = 1;
        max_value = 10;
    } in
    let errors = Int_validation.validation v 10 in
    [%test_eq: error list] [] errors

let%test_unit "Int correct test2" =
    let v = {
        Int_validation.min_value = 1;
        max_value = 10;
    } in
    let errors = Int_validation.validation v 1 in
    [%test_eq: error list] [] errors