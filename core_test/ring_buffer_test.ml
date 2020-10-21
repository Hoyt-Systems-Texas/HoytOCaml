open Core
open HoytCore.Ring_buffer

let%test_unit "min value test" =
  match make 1024l 0L with
  | Some buffer ->
    [%test_eq: Int64.t] (min_index buffer) (-1023L);
    (ignore @@ add buffer 1);
    [%test_eq: Int64.t] (min_index buffer) (-1022L)
  | None ->
    failwith "unable to create the buffer."

let%test_unit "add get test" =
  match make 1024l 0L with 
  | Some buffer ->
    let pos = add buffer 1 in
    [%test_eq: Int.t option] (get buffer pos) (Some 1);
    let pos = add buffer 2 in
    [%test_eq: Int.t option] (get buffer pos) (Some 2);
    [%test_eq: Int32.t] (size buffer) 1024l
  | None ->
    failwith "unable to create the buffer."

let%test_unit "add test end" =
  match make 2l 0L with
  | Some buffer ->
    let pos = add buffer 1 in
    [%test_eq: Int.t option] (get buffer pos) (Some 1);
    let pos = add buffer 2 in
    [%test_eq: Int.t option] (get buffer pos) (Some 2);
    let pos = add buffer 3 in
    [%test_eq: Int.t option] (get buffer pos) (Some 3);
    let pos = add buffer 4 in
    [%test_eq: Int.t option] (get buffer pos) (Some 4);
    let size = size buffer in
    [%test_eq: Int32.t] size 2l
  | None ->
    failwith "unable to create the buffer"

