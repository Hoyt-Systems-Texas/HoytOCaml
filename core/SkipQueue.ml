open Core

type whichQueue =
    | Primary
    | Defer

type 'a t = {
    primary: 'a Queue.t;
    defer: 'a Queue.t;
    whichQueue: whichQueue ref;
}

let make () = {
    primary = Queue.create ();
    defer = Queue.create ();
    whichQueue = ref Primary;
}

let dequeue t =
    match !(t.whichQueue) with 
    | Primary -> 
        Queue.dequeue t.primary
    | Defer ->
        match Queue.dequeue t.defer with
        | Some(a) -> Some(a)
        | None -> 
            let wh = t.whichQueue in wh := Primary;
            Queue.dequeue t.primary


let enqueue t v =
    Queue.enqueue t.primary v;
    ()

let defer t v =
    Queue.enqueue t.defer v;
    ()

let reset t =
    let wh = t.whichQueue in wh := Defer;