open! Core

type 'v record = {
  touched_count: int64 ref;
  (** The touched number. *)
  value: 'v;
}
(** Represents a record stored in the map. *)

type ('k, 'v) queue_entry = {
  key:  'k;
  insert_count: int64;
  (** The initial count when we inserted the value into the queue. *)
  record: 'v record;
  (** The record we are storing. *)
  time: Time_ns.t;
}
(** immutable record for the queue *)

type ('k, 'v) t = {
  keep_for: Time_ns.Span.t;
  hash_tbl: ('k, 'v record) Hashtbl.t;
  queue: ('k, 'v) queue_entry Queue.t;
  current_count: int64 ref;
}

let make key_mod keep_for = 
  let table = Hashtbl.create key_mod in
  let queue = Queue.create () in
  {
    keep_for;
    hash_tbl=table;
    queue;
    current_count=ref 0L;
  }

let clean t =
  let current_time = Time_ns.now () in
  let count = !(t.current_count) in
  let rec mr_clean () =
    match Queue.peek t.queue with
    | Some a ->
      if Time_ns.(<) a.time current_time then
        match Queue.dequeue t.queue with
        | Some v ->
          let touched = v.record.touched_count in 
          if not @@ Int64.(=) !touched v.insert_count then
            let v = { v with 
              insert_count=count;
              time=Time_ns.add (Time_ns.now ()) t.keep_for;
            } in
            Queue.enqueue t.queue v;
          else
            (ignore @@ Hashtbl.find_and_remove t.hash_tbl v.key);
          mr_clean ()
        | None -> ()
      else
        ()
    | None -> () in
  mr_clean ()

let add t key value =
  let count = !(t.current_count) in 
  let next_count = Int64.(+) count 1L in 
  let record = {
    touched_count=ref next_count;
    value;
  } in
  let queue_record = {
    key;
    insert_count=next_count;
    record;
    time=Time_ns.add (Time_ns.now ()) t.keep_for;
  } in
  match Hashtbl.add t.hash_tbl ~key ~data:record with 
  | `Ok -> Queue.enqueue t.queue queue_record;
    `Ok
  | `Duplicate -> ();
    `Duplicate

let get t key =
  match Hashtbl.find t.hash_tbl key with
  | Some v ->
    let count = v.touched_count in
    count := Int64.(+) !count 1L;
    Some v.value
  | None -> None

let remove t key =
  (ignore @@ Hashtbl.find_and_remove t.hash_tbl key)