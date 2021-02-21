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
  match Pow.to_power_of_2 (Int64.to_int32 key_count) with
  | Some i ->
    let store_size = Int64.mul (Int64.of_int total_edges) 2L in
    let bit_store = Bit_store.make store_size (Int32.to_int i) in
    let _last_id  = List.fold_left (fun pos (v1, v2) ->
      match (Hashtbl.find_opt vertex_to_id v1, Hashtbl.find_opt vertex_to_id v2) with
      | (Some(v1), Some(v2)) ->
        (* Write the first edge at that position.*)
        Bit_store.write bit_store pos v1;
        (* Get the ending vector at that position.*)
        let pos = Int64.add 1L pos in
        Bit_store.write bit_store pos v2;
        (* Got to the next pair.*)
        Int64.add pos 1L
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

let find_ t id =
  match Bit_store.binary_search t.edges id 2L with
  | Some pos -> 
    let rec find_vertexes pos values =
      match Bit_store.read_opt t.edges pos with
      | Some value ->
        if value = id then
          let value_pos = Int64.add pos 1L in
          let v2 = Bit_store.read t.edges value_pos |> Int64.to_int in
          let next_pos = Int64.add pos 2L in
          find_vertexes next_pos (v2::values)
        else
          values |> List.rev
      | None -> values |> List.rev in
    find_vertexes pos []
  | None -> []

let find t vertex =
  match Hashtbl.find_opt t.vertex_to_id vertex with
  | Some id ->  
    find_ t id
    |> List.map (fun id -> Array.unsafe_get t.id_to_vertex id)
  | None ->
    []

let bfs t v1 v2 =
  match ((Hashtbl.find_opt t.vertex_to_id v1), (Hashtbl.find_opt t.vertex_to_id v2)) with
  | (Some(start), Some(end_)) -> 
    let end_int = Int64.to_int end_ in
    if start = end_ then
      Some [v1]
    else
      let previous_nodes = Hashtbl.create 12 in
      let vertexes = Queue.create () in
      let start_vec = Bit_store.create_new t.edges 1L in
      Bit_store.write start_vec 0L start;
      Hashtbl.add previous_nodes start true;
      Queue.add (0L, start_vec) vertexes;
      let rec search () =
        match Queue.take_opt vertexes with
        | Some (pos, path) -> 
          let current_node = Bit_store.read path pos in
          (* Now we need to get the related nodes and add them to the queue.*)
          let related = find_ t current_node in
          let rec check_related related =
            match related with
            | [] -> None
            | head::rest -> 
              if head = end_int then
                Some head
              else
                let next_pos = Int64.add pos 1L in
                let new_size = Int64.add next_pos 1L in
                let new_store = Bit_store.clone path new_size in
                Bit_store.write new_store next_pos (Int64.of_int head);
                Queue.add (next_pos, new_store) vertexes;
                check_related rest
            in
          (match check_related related with
          | Some last -> 
            let length = Bit_store.length path
              |> Int64.of_int in
            let rec output_path pos num_path =
              if pos < length then
                let next_value = Bit_store.read path pos in
                output_path (Int64.add 1L pos) (next_value::num_path)
              else
                num_path
              in
            (output_path 0L [])
            (* Get the output path values. *)
            |> List.map (fun idx -> Array.get t.id_to_vertex (Int64.to_int idx))
            (* Add the last node to the search *)
            |> List.cons (Array.get t.id_to_vertex last)
            (* Reverse the path. *)
            |> List.rev 
            |> Some
          | None -> search ())
        | _ -> None
      in
      search ()
  | _ -> None