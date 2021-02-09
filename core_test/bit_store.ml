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
  [%test_eq: int64] (Bit_store.read bit_store 7L) 8L

 let%test_unit "Binary search test." =
  let bit_store = Bit_store.make 9L 10 in
  Bit_store.write bit_store 0L 1L;
  Bit_store.write bit_store 1L 2L;
  Bit_store.write bit_store 2L 3L;
  Bit_store.write bit_store 3L 4L;
  Bit_store.write bit_store 4L 5L;
  Bit_store.write bit_store 5L 5L;
  Bit_store.write bit_store 6L 8L;
  Bit_store.write bit_store 7L 9L;
  Bit_store.write bit_store 8L 1023L;
  [%test_eq: int64 option] (Bit_store.binary_search bit_store 1L 1L) (Some 0L);
  [%test_eq: int64 option] (Bit_store.binary_search bit_store 5L 1L) (Some 4L);
  [%test_eq: int64 option] (Bit_store.binary_search bit_store 1023L 1L) (Some 8L);
  [%test_eq: int64 option] (Bit_store.binary_search bit_store 80L 1L) None

 let%test_unit "Binary search test even." =
  let bit_store = Bit_store.make 10L 10 in
  Bit_store.write bit_store 0L 1L;
  Bit_store.write bit_store 1L 2L;
  Bit_store.write bit_store 2L 3L;
  Bit_store.write bit_store 3L 4L;
  Bit_store.write bit_store 4L 5L;
  Bit_store.write bit_store 5L 6L;
  Bit_store.write bit_store 6L 8L;
  Bit_store.write bit_store 7L 9L;
  Bit_store.write bit_store 8L 10L;
  Bit_store.write bit_store 9L 11L;
  [%test_eq: int64 option] (Bit_store.binary_search bit_store 1L 1L) (Some 0L);
  [%test_eq: int64 option] (Bit_store.binary_search bit_store 5L 1L) (Some 4L);
  [%test_eq: int64 option] (Bit_store.binary_search bit_store 11L 1L) (Some 9L);
  [%test_eq: int64 option] (Bit_store.binary_search bit_store 12L 1L) None