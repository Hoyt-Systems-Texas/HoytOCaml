open! Core

(* The type for the user id.*)
type user_id = int64

(* The type for the nodes. *)
type node_id = int

type db_result = (unit, Caqti_error.t) result Lwt.t

module type Diff_repository = sig
  (* The type for the database.*)
  type db

  (* Used to add a db value to the database. *)
  val add: db -> user_id -> (module Connection.Connection) -> db_result

  (* Updates a record in the database. *)
  val update: db -> user_id -> (module Connection.Connection) -> db_result

  (* Deletes a record for the repository. *)
  val delete: db -> user_id -> (module Connection.Connection) -> db_result

end

module type Map_record = sig

  (* The data type for the domain.*)
  type domain

  (* The type for the database. *)
  type db

end

module type Convert_record = sig
  include Map_record

  (* Converts the value to the domain. *)
  val to_db: domain -> db

  (* Checks to see if the domain are equal. *)
  val equal: db -> db -> bool

end

module Update_records(Diff: Diff_repository) = struct

  type t = {
    id: node_id;
    add: Diff.db list ref;
    update: Diff.db list ref;
    delete: Diff.db list ref;
  }

  let create node_id =
    {
      id = node_id;
      add = ref [];
      update = ref [];
      delete = ref [];
    }

  let add db t =
    let add_values = t.add in
    add_values := db::(!add_values);
    t

  let update db t =
    let update_values = t.update in
    update_values := db::(!update_values);
    t

  let delete db t =
    let delete_values = t.delete in
    delete_values := db::(!delete_values);
    t

  let add_values user_id conn t prev =
    let values = t.add in
    List.fold !values ~init:prev ~f:(fun acc db ->
      Lwt.bind acc (fun _ -> Diff.add db user_id conn))
  
  let update_values user_id conn t prev =
    let values = t.update in
    List.fold !values ~init:prev ~f:(fun acc db ->
      Lwt.bind acc (fun _ -> Diff.update db user_id conn))

  let delete_values user_id conn t prev =
    let values = t.delete in
    List.fold !values ~init:prev ~f:(fun acc db ->
      Lwt.bind acc (fun _ -> Diff.delete db user_id conn))

  (** Used to create an update function. 
conn - The database connection.
t - The types to execute.
user_id - The id of the user who is making the update.
*)
  let update_func conn t user_id =
    let open Lwt in
    let initial = return (Ok ()) in
    add_values user_id conn t initial
    |> update_values user_id conn t
    |> delete_values user_id conn t

end

module Node_updates = struct

  type update_func = user_id -> db_result

  type t = {
    dict: (node_id, update_func) Hashtbl.t
  }

  let create () =
    {
      dict = Hashtbl.create ~growth_allowed:true ~size:16 (module Int)
    }

end

module Child_relationships(Record: Map_record) = struct

  type t = {
      many_to_one: int
    }
end
