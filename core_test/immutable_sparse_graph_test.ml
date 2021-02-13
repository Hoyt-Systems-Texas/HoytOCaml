open! Core
open! HoytCore

let%test_unit "Find the position of the values." =
  let edges = [
    ("a", "b");
    ("a", "d");
    ("b", "c");
    ("c", "f");
    ("c", "a");
    ("d", "c");
    ("f", "d");
    ("f", "a");
    ("f", "c");
    ("f", "b");
    ("f", "g");
    ("g", "b");
    ("g", "a");
    ("g", "c");
    ("g", "d");
  ] in
  let graph = Immutable_sparse_graph.make edges "" in
  match graph with
  | Some graph ->
    let path = Immutable_sparse_graph.find graph "c" in
    [%test_eq: string list] path ["f"; "a"];
  | None ->
    [%test_eq: bool] true false

let%test_unit "Find the position of the values a." =
  let edges = [
    ("a", "b");
    ("a", "d");
    ("b", "c");
    ("c", "f");
    ("c", "a");
    ("d", "c");
    ("f", "d");
    ("f", "a");
    ("f", "c");
    ("f", "b");
    ("f", "g");
    ("g", "b");
    ("g", "a");
    ("g", "c");
    ("g", "d");
  ] in
  let graph = Immutable_sparse_graph.make edges "" in
  match graph with
  | Some graph ->
    let path = Immutable_sparse_graph.find graph "a" in
    [%test_eq: string list] path ["b"; "d"];
  | None ->
    [%test_eq: bool] true false

let%test_unit "Find the position of the values b." =
  let edges = [
    ("a", "b");
    ("a", "d");
    ("b", "c");
    ("c", "f");
    ("c", "a");
    ("d", "c");
    ("f", "d");
    ("f", "a");
    ("f", "c");
    ("f", "b");
    ("f", "g");
    ("g", "b");
    ("g", "a");
    ("g", "c");
    ("g", "d");
  ] in
  let graph = Immutable_sparse_graph.make edges "" in
  match graph with
  | Some graph ->
    let path = Immutable_sparse_graph.find graph "b" in
    [%test_eq: string list] path ["c"];
  | None ->
    [%test_eq: bool] true false

let%test_unit "Find the position of the values f." =
  let edges = [
    ("a", "b");
    ("a", "d");
    ("b", "c");
    ("c", "f");
    ("c", "a");
    ("d", "c");
    ("f", "d");
    ("f", "a");
    ("f", "c");
    ("f", "b");
    ("f", "g");
    ("g", "b");
    ("g", "a");
    ("g", "c");
    ("g", "d");
  ] in
  let graph = Immutable_sparse_graph.make edges "" in
  match graph with
  | Some graph ->
    let path = Immutable_sparse_graph.find graph "f" in
    [%test_eq: string list] path ["d";"a";"c";"b";"g"];
  | None ->
    [%test_eq: bool] true false

let%test_unit "Find the position of the values g." =
  let edges = [
    ("a", "b");
    ("a", "d");
    ("b", "c");
    ("c", "f");
    ("c", "a");
    ("d", "c");
    ("f", "d");
    ("f", "a");
    ("f", "c");
    ("f", "b");
    ("f", "g");
    ("g", "b");
    ("g", "a");
    ("g", "c");
    ("g", "d");
  ] in
  let graph = Immutable_sparse_graph.make edges "" in
  match graph with
  | Some graph ->
    let path = Immutable_sparse_graph.find graph "g" in
    [%test_eq: string list] path ["b";"a";"c";"d";];
  | None ->
    [%test_eq: bool] true false
    