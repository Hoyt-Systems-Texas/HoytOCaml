open! Core

let nullable_string s =
  if String.is_empty s then
    None
  else
    Some s

let to_proto_string s =
  match s with
  | Some s -> s
  | None -> ""