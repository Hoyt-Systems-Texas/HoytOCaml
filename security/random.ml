open! Core

let session size =
    let key = Mirage_crypto_rng.generate size in
    Base64.encode_string @@ Cstruct.to_string key