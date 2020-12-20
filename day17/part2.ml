
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

let cross_product4 xs ys zs ts =
  cross_product (cross_product xs ys) (cross_product zs ts) |> List.map (fun ((x, y), (z, t)) -> (x, y, z, t))

module Conway = struct

  type state =
    | Inactive
    | Active

  type grid = {
      array : state Array.t;
      width : int;
      height : int;
      length : int;
      depth: int
    }

  let index grid x y z t = x + grid.width * (y + grid.height * (z + grid.length * t))

  let inverse_index w h l _ index =
    (index mod w, (index / w) mod h, (index / (w * h)) mod l, index / (w * h * l))

  let empty_grid w h l d = {
      array = Array.make (w * h * l * d) Inactive;
      width = w;
      height = h;
      length = l;
      depth = d;
    }

  let init w h l d f =
    let f' idx =
      let (x, y, z, t) = inverse_index w h l d idx in
      f x y z t in
    {
      array = Array.init (w * h * l * d) f';
      width = w;
      height = h;
      length = l;
      depth = d;
    }

  let in_bounds grid x y z t =
    x >= 0 && y >= 0 && z >= 0 && t >= 0 &&
      x < grid.width && y < grid.height && z < grid.length && t < grid.depth

  let get grid x y z t = Array.get grid.array (index grid x y z t)

  let set grid x y z t v = Array.set grid.array (index grid x y z t) v

  let get_opt grid x y z t =
    if in_bounds grid x y z t then
      Some (get grid x y z t)
    else
      None

  let grid_of_text lines =
    let width = List.hd lines |> String.length in
    let height = List.length lines in
    let length = 1 in
    let depth = 1 in
    let init_fn x y _ _ =
      let char = String.get (List.nth lines y) x in
      if char = '#' then Active else Inactive in
    init width height length depth init_fn

  let pad grid amount =
    let width  = grid.width  + amount * 2 in
    let height = grid.height + amount * 2 in
    let length = grid.length + amount * 2 in
    let depth  = grid.depth  + amount * 2 in
    let init_fn x y z t =
      Option.value (get_opt grid (x - amount) (y - amount) (z - amount) (t - amount)) ~default:Inactive in
    init width height length depth init_fn

  let count_active grid =
    grid.array |> Array.to_list |> List.filter (fun x -> x = Active) |> List.length

  let all_neighbors x y z t =
    let possibilities = cross_product4 [x - 1; x; x + 1] [y - 1; y; y + 1] [z - 1; z; z + 1] [t - 1; t; t + 1] in
    List.filter (fun pos -> pos <> (x, y, z, t)) possibilities

  let count_active_neighbors grid x y z t =
    all_neighbors x y z t |>
      List.map (fun (x', y', z', t') -> get_opt grid x' y' z' t' = Some Active) |>
      List.filter (fun a -> a) |>
      List.length

  let conway grid =
    let init_fn x y z t =
      let neighbors = count_active_neighbors grid x y z t in
      match get grid x y z t with
      | Inactive -> if neighbors = 3 then Active else Inactive
      | Active -> if neighbors = 2 || neighbors = 3 then Active else Inactive in
    init grid.width grid.height grid.length grid.depth init_fn

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
