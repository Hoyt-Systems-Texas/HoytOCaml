open Core
open HoytCore

let%test_unit "Skip queue add test" =
  let span = Time_ns.Span.create ~sec:(30) () in
  let table = Expirable_hash.make (module Int64) span in
  [%test_eq: [`Ok | `Duplicate]] (Expirable_hash.add table 1L 2) `Ok

let%test_unit "Skip queue duplicate test" =
  let span = Time_ns.Span.create ~sec:(30) () in
  let table = Expirable_hash.make (module Int64) span in
  [%test_eq: [`Ok | `Duplicate]] (Expirable_hash.add table 1L 2) `Ok;
  [%test_eq: [`Ok | `Duplicate]] (Expirable_hash.add table 1L 2) `Duplicate

let%test_unit "Get value test" =
  let span = Time_ns.Span.create ~sec:(30) () in
  let table = Expirable_hash.make (module Int64) span in
  [%test_eq: [`Ok | `Duplicate]] (Expirable_hash.add table 1L 2) `Ok;
  [%test_eq: int option] (Expirable_hash.get table 1L) (Some(2))

let%test_unit "Remove value test"=
  let span = Time_ns.Span.create ~sec:(30) () in
  let table = Expirable_hash.make (module Int64) span in
  [%test_eq: [`Ok | `Duplicate]] (Expirable_hash.add table 1L 2) `Ok;
  Expirable_hash.remove table 1L;
  [%test_eq: int option] (Expirable_hash.get table 1L) (None)

let%test_unit "Clean value test"=
  let span = Time_ns.Span.create ~sec:(30) () in
  let table = Expirable_hash.make (module Int64) span in
  [%test_eq: [`Ok | `Duplicate]] (Expirable_hash.add table 1L 2) `Ok;
  Expirable_hash.clean table;
  [%test_eq: int option] (Expirable_hash.get table 1L) (Some(2))
  
let%test_unit "Clean value remove test"=
  let span = Time_ns.Span.create ~sec:(-3) () in
  let table = Expirable_hash.make (module Int64) span in
  [%test_eq: [`Ok | `Duplicate]] (Expirable_hash.add table 1L 2) `Ok;
  Expirable_hash.clean table;
  [%test_eq: int option] (Expirable_hash.get table 1L) (None)

let%test_unit "Clean value remove test"=
  let span = Time_ns.Span.create ~ms:(1) () in
  let table = Expirable_hash.make (module Int64) span in
  [%test_eq: [`Ok | `Duplicate]] (Expirable_hash.add table 1L 2) `Ok;
  [%test_eq: int option] (Expirable_hash.get table 1L) (Some(2));
  Thread.delay 0.005;
  Expirable_hash.clean table;
  [%test_eq: int option] (Expirable_hash.get table 1L) (Some(2))