
module FileReader = struct

  let read_line ic =
    try
      Some (input_line ic)
    with End_of_file ->
      None

  let rec read_lines acc ic =
    match read_line ic with
    | None -> List.rev acc
    | Some line -> read_lines (line :: acc) ic

  let lines_of_file filename =
    let ic = open_in filename in
    let lines = read_lines [] ic in
    close_in ic;
    lines

end

let rec cross_product xs ys =
  match xs with
  | [] -> []
  | x :: xs -> List.append (List.map (fun y -> (x, y)) ys) (cross_product xs ys)

let cross_product3 xs ys zs =
  cross_product (cross_product xs ys) zs |> List.map (fun ((x, y), z) -> (x, y, z))

module Conway = struct

  type state =
    | Inactive
    | Active

  type grid = {
      array : state Array.t;
      width : int;
      height : int;
      length : int;
    }

  let index grid x y z = x + grid.width * (y + grid.height * z)

  let inverse_index w h _ index =
    (index mod w, (index / w) mod h, index / (w * h))

  let empty_grid w h l = {
      array = Array.make (w * h * l) Inactive;
      width = w;
      height = h;
      length = l;
    }

  let init w h l f =
    let f' idx =
      let (x, y, z) = inverse_index w h l idx in
      f x y z in
    {
      array = Array.init (w * h * l) f';
      width = w;
      height = h;
      length = l;
    }

  let in_bounds grid x y z =
    x >= 0 && y >= 0 && z >= 0 &&
      x < grid.width && y < grid.height && z < grid.length

  let get grid x y z = Array.get grid.array (index grid x y z)

  let set grid x y z v = Array.set grid.array (index grid x y z) v

  let get_opt grid x y z =
    if in_bounds grid x y z then
      Some (get grid x y z)
    else
      None

  let grid_of_text lines =
    let width = List.hd lines |> String.length in
    let height = List.length lines in
    let length = 1 in
    let init_fn x y _ =
      let char = String.get (List.nth lines y) x in
      if char = '#' then Active else Inactive in
    init width height length init_fn

  let pad grid amount =
    let width  = grid.width  + amount * 2 in
    let height = grid.height + amount * 2 in
    let length = grid.length + amount * 2 in
    let init_fn x y z = Option.value (get_opt grid (x - amount) (y - amount) (z - amount)) ~default:Inactive in
    init width height length init_fn

  let count_active grid =
    grid.array |> Array.to_list |> List.filter (fun x -> x = Active) |> List.length

  let all_neighbors x y z =
    let possibilities = cross_product3 [x - 1; x; x + 1] [y - 1; y; y + 1] [z - 1; z; z + 1] in
    List.filter (fun pos -> pos <> (x, y, z)) possibilities

  let count_active_neighbors grid x y z =
    all_neighbors x y z |>
      List.map (fun (x', y', z') -> get_opt grid x' y' z' = Some Active) |>
      List.filter (fun a -> a) |>
      List.length

  let conway grid =
    let init_fn x y z =
      let neighbors = count_active_neighbors grid x y z in
      match get grid x y z with
      | Inactive -> if neighbors = 3 then Active else Inactive
      | Active -> if neighbors = 2 || neighbors = 3 then Active else Inactive in
    init grid.width grid.height grid.length init_fn

end

let rec iterate_times n f x =
  if n = 0 then
    x
  else
    iterate_times (n - 1) f (f x)

let () =
  let lines = FileReader.lines_of_file "input.txt" in
  let initial_grid = Conway.grid_of_text lines in
  let padded_grid = Conway.pad initial_grid 6 in
  let final_grid = iterate_times 6 Conway.conway padded_grid in
  print_endline (string_of_int (Conway.count_active final_grid))
