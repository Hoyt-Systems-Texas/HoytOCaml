open Core
open HoytCore.Pow

let%test_unit "is_power_of_2" =
  [%test_eq: bool] (is_power_2 2l) true;
  [%test_eq: bool] (is_power_2 256l) true

let%test_unit "next power of 2 test" =
  [%test_eq: Int32.t] (next_power 15l) 16l;
  [%test_eq: Int32.t] (next_power 31l) 32l;
  [%test_eq: Int32.t] (next_power 1023l) 1024l;
  [%test_eq: Int32.t] (next_power 65535l) 65536l

let%test_unit "to_power_of_2" =
  [%test_eq: Int32.t option] (to_power_of_2 15l) (Some 16l);
  [%test_eq: Int32.t option] (to_power_of_2 16l) (Some 16l);
  [%test_eq: Int32.t option] (to_power_of_2 65535l) (Some 65536l);
  [%test_eq: Int32.t option] (to_power_of_2 65536l) (Some 65536l)