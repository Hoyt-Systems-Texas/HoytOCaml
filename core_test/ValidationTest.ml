open OUnit2
open HoytCore.Validation

let empty_list = []
let list_a = [1;2;3]

let test_required_missing _ =
  let v = {
    StringValidation.required = true;
    minLength = 0;
    maxLength = 100
  } in
  let errors = StringValidation.validation v "" in
  (* Check if the list is empty. *)
  assert_equal 1 (List.length errors);
  assert_equal [Required] errors

let test_required_true _ =
  let v = {
    StringValidation.required = true;
    minLength = 0;
    maxLength = 100
  } in
  let errors = StringValidation.validation v "hi" in
  assert_equal 0 @@ List.length errors

let test_min_length _ =
  let v = {
    StringValidation.required = true;
    minLength = 2;
    maxLength = 3;
  } in
  let errors = StringValidation.validation v "a" in
  assert_equal 1 @@ List.length errors;
  assert_equal [MinLength(2)] errors

let test_max_length _ =
  let v = {
    StringValidation.required = true;
    minLength = 0;
    maxLength = 10;
  } in
  let errors = StringValidation.validation v "12345678901" in
  assert_equal 1 @@ List.length errors;
  assert_equal [MaxLength(10)] errors

let suite =
  "String Validation Test" >::: [
    "string test required missing" >:: test_required_missing;
    "String test required true" >:: test_required_true;
    "String minlength fail" >:: test_min_length;
    "String maxlength fail" >:: test_max_length;
  ]

let () = 
  run_test_tt_main suite
