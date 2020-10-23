open! Core

let session size =
  let key = Mirage_crypto_rng.generate size in
  Base64.encode_string @@ Cstruct.to_string key

let random_int64 () =
  let key = Mirage_crypto_rng.generate 8 in
  Cstruct.LE.get_uint64 key 0
