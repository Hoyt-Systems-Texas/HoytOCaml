open Core
open HoytCore

let%test_unit "Skip queue test 1" =
    let queue = Skip_queue.make () in
    Skip_queue.enqueue queue 1;
    Skip_queue.enqueue queue 2;
    let result = Skip_queue.dequeue queue in
    [%test_eq: int option] result (Some(1))

let%test_unit "Skip queue test defer" =
    let queue = Skip_queue.make () in
    Skip_queue.defer queue 1;
    Skip_queue.enqueue queue 2;
    Skip_queue.enqueue queue 3;
    Skip_queue.enqueue queue 4;
    let result = Skip_queue.dequeue queue in
    [%test_eq: int option] result (Some(2));
    Skip_queue.reset queue;
    let result = Skip_queue.dequeue queue in
    [%test_eq: int option] result (Some(1));
    let result = Skip_queue.dequeue queue in
    [%test_eq: int option] result (Some(3));