open! Core

let nullable_string s =
  if String.is_empty s then
    None
  else
    Some s