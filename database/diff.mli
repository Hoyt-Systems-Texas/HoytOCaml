open! Core

(* The type for the user id.*)
type user_id = int64

module type Diff_repository = sig
  (* The type for the database.*)
  type db

  (* Used to add a db value to the database. *)
  val add: db -> user_id -> (module Connection.Connection) -> (db, Caqti_error.t) result Lwt.t

  (* Updates a record in the database. *)
  val update: db -> user_id -> (module Connection.Connection) -> (db, Caqti_error.t) result Lwt.t

  (* Deletes a record for the repository. *)
  val delete: db -> user_id -> (module Connection.Connection) -> (db, Caqti_error.t) result Lwt.t

end

module type Map_record = sig

  (* The data type for the domain.*)
  type domain
  (* The type for the database.*)
  type db
  (* Update the domain record. *)
  val to_db: domain -> db
  (* Converts the db value to the domain.*)
  val to_domain: db -> domain
  (* Checks to see if the db values are equal.*)
  val equal: db -> db -> bool

end
