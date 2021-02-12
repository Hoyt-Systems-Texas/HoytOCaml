type 'a edges = ('a * 'a)

type 'a t = {
  vertex_to_id: ('a, int64) Hashtbl.t;
  id_to_vertex: 'a array;
  edges: Bit_store.t;
  total_edges: int;
  key_count: int;
}

let make edges default_edge =
  let vertex_to_id = Hashtbl.create 256 in
  let total_edges = List.length edges in
  let last_id = List.fold_left (fun i (v1, _) ->
    match Hashtbl.find_opt vertex_to_id v1 with
    | Some _ -> i
    | None -> 
      (Hashtbl.add vertex_to_id v1 i;
      Int64.add i 1L)) 0L edges in
  let key_count = List.fold_left (fun i (_, v2) ->
    match Hashtbl.find_opt vertex_to_id v2 with
    | Some _ -> i
    | None ->
      (Hashtbl.add vertex_to_id v2 i;
      Int64.add i 1L)) last_id edges in
  let id_to_vertex = Hashtbl.fold (fun key value id_to_vertex ->
    Array.set id_to_vertex (Int64.to_int value) key;
    id_to_vertex) vertex_to_id (Array.make (Int64.to_int key_count) default_edge) in
  (* Now we need to write the graph to the bit store. *)
  match Pow.to_power_of_2 (Int32.of_int total_edges) with
  | Some i ->
    let store_size = Int64.mul (Int64.of_int total_edges) 2L in
    let bit_store = Bit_store.make store_size (Int32.to_int i) in
    let _last_id  = List.fold_left (fun pos (v1, v2) ->
      match (Hashtbl.find_opt vertex_to_id v1, Hashtbl.find_opt vertex_to_id v2) with
      | (Some(v1), Some(v2)) ->
        Bit_store.write bit_store pos v1;
        let pos = Int64.add 1L pos in
        Bit_store.write bit_store pos v2;
        pos
      | _ -> pos
      ) 0L edges in
    Some {
      vertex_to_id;
      id_to_vertex;
      edges = bit_store;
      total_edges;
      key_count = Int64.to_int key_count;
    }
  | None -> None