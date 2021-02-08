open Core
open HoytCore

let%test_unit "read and write test" =
  let bit_store = Bit_store.make 9L 10 in
  Bit_store.write bit_store 0L 1L;
  Bit_store.write bit_store 1L 2L;
  Bit_store.write bit_store 2L 3L;
  Bit_store.write bit_store 3L 4L;
  Bit_store.write bit_store 4L 5L;
  Bit_store.write bit_store 5L 6L;
  Bit_store.write bit_store 6L 1023L;
  Bit_store.write bit_store 7L 8L;
  Bit_store.write bit_store 8L 9L;
  [%test_eq: int64] (Bit_store.read bit_store 1L) 2L;
  [%test_eq: int64] (Bit_store.read bit_store 2L) 3L;
  [%test_eq: int64] (Bit_store.read bit_store 3L) 4L;
  [%test_eq: int64] (Bit_store.read bit_store 4L) 5L;
  [%test_eq: int64] (Bit_store.read bit_store 5L) 6L;
  [%test_eq: int64] (Bit_store.read bit_store 6L) 1023L;
  [%test_eq: int64] (Bit_store.read bit_store 7L) 8L;
  [%test_eq: int64] (Bit_store.read bit_store 8L) 9L;