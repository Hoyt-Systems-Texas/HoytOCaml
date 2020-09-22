open Core
open HoytCore

let%test_unit "Skip queue test 1" =
    let queue = SkipQueue.make () in
    SkipQueue.enqueue queue 1;
    SkipQueue.enqueue queue 2;
    let result = SkipQueue.dequeue queue in
    [%test_eq: int option] result (Some(1))

let%test_unit "Skip queue test defer" =
    let queue = SkipQueue.make () in
    SkipQueue.defer queue 1;
    SkipQueue.enqueue queue 2;
    SkipQueue.enqueue queue 3;
    SkipQueue.enqueue queue 4;
    let result = SkipQueue.dequeue queue in
    [%test_eq: int option] result (Some(2));
    SkipQueue.reset queue;
    let result = SkipQueue.dequeue queue in
    [%test_eq: int option] result (Some(1));
    let result = SkipQueue.dequeue queue in
    [%test_eq: int option] result (Some(3));