open Core

type which_queue =
  | Primary
  | Defer

type 'a t = {
  primary: 'a Queue.t;
  defer: 'a Queue.t;
  which_queue: which_queue ref;
}

let make () = {
  primary = Queue.create ();
  defer = Queue.create ();
  which_queue = ref Primary;
}

let dequeue t =
  match !(t.which_queue) with 
  | Primary -> 
    Queue.dequeue t.primary
  | Defer ->
    match Queue.dequeue t.defer with
    | Some(a) -> Some(a)
    | None -> 
      let wh = t.which_queue in wh := Primary;
      Queue.dequeue t.primary


let enqueue t v =
  Queue.enqueue t.primary v;
  ()

let defer t v =
  Queue.enqueue t.defer v;
  ()

let reset t =
  let wh = t.which_queue in wh := Defer;