open! Core
open Lwt.Infix

module DataStoreResult = struct

  type 'v t = 
    | NoValue
    | Available of 'v
    | Error

end

module type Data_type = sig
  type key

  type record

  val fetch: key -> record DataStoreResult.t Lwt.t

end

module Make_data_type(D: Data_type) = struct

  type node =
    | Pending of D.record DataStoreResult.t Lwt.u list ref
    | Available of D.record
    | Refresh of D.record
    | Error

  type t = {
    table: (D.key, node) Hashtbl.t;
    version_num: int64 ref;
    (** A version number to use to keep track of changes. *)
  }

  let make key_mod =
    {
      table=Hashtbl.create key_mod;
      version_num=ref 0L;
    }

  let update t k record = 
    let v = t.version_num in
    let version = Int64.(+) !v 1L in
    v := version;
    Hashtbl.update t.table k ~f:(fun _ -> 
      Available record
    );
    ()
  
  let refresh t k =
    match Hashtbl.find t.table k with
    | Some(v) -> (
      match v with
      | Pending _ -> ()
      | Available m -> 
        Hashtbl.update t.table k ~f:(fun _ -> Refresh m);
        D.fetch k
        >>= (fun v ->
          let value = match v with
          | DataStoreResult.Error
          | DataStoreResult.NoValue -> Error
          | DataStoreResult.Available v -> Available v in 
          Hashtbl.update t.table k ~f:(fun _ -> value);
          Lwt.return_unit)
        |> Lwt.ignore_result
      | Refresh _ -> ()
      | Error -> ()
    )
    | None -> ()


  let notfy t k v =
    match Hashtbl.find t.table k with
    | Some Pending a ->
      (ignore (List.for_all !a ~f:(fun def ->
        Lwt.wakeup def v;
        true): bool));
      ()
    | _ -> ()

    
  let get t k =
    match Hashtbl.find t.table k with
    | Some(v) -> (
      match v with 
      | Pending waiters -> 
        let (def, fl) = Lwt.wait () in 
        let current = (!waiters) in
        waiters := fl :: current;
        def
      | Refresh v
      | Available v -> Lwt.return @@ DataStoreResult.Available v
      | Error -> Lwt.return DataStoreResult.NoValue)
    | None -> 
      let (def, fl) = Lwt.wait () in
      let waiters = Pending(ref [fl]) in
      Hashtbl.add_exn t.table ~key:k ~data:waiters;
      D.fetch k
      >>= (fun v ->
        let value = match v with
        | DataStoreResult.Error 
        | DataStoreResult.NoValue -> Error
        | DataStoreResult.Available v -> Available v in
        notfy t k v;
        Hashtbl.update t.table k ~f:(fun _ -> value);
        Lwt.return_unit)
      |> Lwt.ignore_result;
      def

end