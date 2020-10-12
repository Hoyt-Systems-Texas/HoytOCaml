open! Core
open! Hoyt_security


let%test_unit "Random generate test" =
    Mirage_crypto_rng_unix.initialize ();
    (ignore @@ Random.session 32);