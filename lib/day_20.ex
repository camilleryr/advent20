defmodule Day20 do
  def test_input do
    """
    Tile 2311:
    ..##.#..#.
    ##..#.....
    #...##..#.
    ####.#...#
    ##.##.###.
    ##...#.###
    .#.#.#..##
    ..#....#..
    ###...#.#.
    ..###..###

    Tile 1951:
    #.##...##.
    #.####...#
    .....#..##
    #...######
    .##.#....#
    .###.#####
    ###.##.##.
    .###....#.
    ..#.#..#.#
    #...##.#..

    Tile 1171:
    ####...##.
    #..##.#..#
    ##.#..#.#.
    .###.####.
    ..###.####
    .##....##.
    .#...####.
    #.##.####.
    ####..#...
    .....##...

    Tile 1427:
    ###.##.#..
    .#..#.##..
    .#.##.#..#
    #.#.#.##.#
    ....#...##
    ...##..##.
    ...#.#####
    .#.####.#.
    ..#..###.#
    ..##.#..#.

    Tile 1489:
    ##.#.#....
    ..##...#..
    .##..##...
    ..#...#...
    #####...#.
    #..#.#.#.#
    ...#.#.#..
    ##.#...##.
    ..##.##.##
    ###.##.#..

    Tile 2473:
    #....####.
    #..#.##...
    #.##..#...
    ######.#.#
    .#...#.#.#
    .#########
    .###.#..#.
    ########.#
    ##...##.#.
    ..###.#.#.

    Tile 2971:
    ..#.#....#
    #...###...
    #.#.###...
    ##.##..#..
    .#####..##
    .#..####.#
    #..#.#..#.
    ..####.###
    ..#.#.###.
    ...#.#.#.#

    Tile 2729:
    ...#.#.#.#
    ####.#....
    ..#.#.....
    ....#..#.#
    .##..##.#.
    .#.####...
    ####.#.#..
    ##.####...
    ##..#.##..
    #.##...##.

    Tile 3079:
    #.#.#####.
    .#..######
    ..#.......
    ######....
    ####.#..#.
    .#...#.##.
    #.#####.##
    ..#.###..ea
    ..#.......
    ..#.###...
    """
  end

  def sea_monster do
    """
    ------------------O-
    O----OO----OO----OOO
    -O--O--O--O--O--O---
    """
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce([], fn {line, x_index}, acc ->
      line
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"-", _}, acc -> acc
        {"O", y_index}, acc -> [{x_index, y_index} | acc]
      end)
    end)
  end

  def input_edges, do: [3593, 2797, 3167, 3517]
  def test_input_edges, do: [1171, 1951, 2971, 3079]

  def solve_part_1(input) do
    tiles = input |> parse() |> get_edges

    tiles
    |> Enum.filter(fn {tile_id, tile_edges} ->
      tile_edges
      |> Enum.map(&border?(&1, Map.delete(tiles, tile_id)))
      |> Enum.filter(& &1)
      |> length()
      |> Kernel.==(2)
    end)
    |> Enum.reduce(1, fn {tile_id, _}, acc -> acc * tile_id end)
  end

  def solve_part_2(input, corners \\ input_edges()) do
    tiles =
      input
      |> parse()
      |> Map.new(fn {tile_id, grid} ->
        grid =
          grid
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {row, y_index}, cord_map ->
            row
            |> String.graphemes()
            |> Enum.with_index()
            |> Enum.reduce(cord_map, fn {cell, x_index}, inner_cord_map ->
              Map.put(inner_cord_map, {x_index, y_index}, cell)
            end)
          end)

        {tile_id, grid}
      end)

    dimensions = tiles |> map_size() |> :math.sqrt() |> floor()

    dimensions
    |> build_grid(corners, tiles)
    |> Map.new(fn {{x, y}, cell} -> {{x - 1, y - 1}, cell} end)
    |> hunt(sea_monster())
    |> Enum.filter(fn {_cord, cell} -> cell == "#" end)
    |> Enum.count()
  end

  def hunt(grid, sea_monster, r \\ 0) do
    {num, transformed} =
      grid
      |> Enum.reduce({0, grid}, fn {{x, y}, _cell}, {num, acc_grid} = acc ->
        sea_monster
        |> Enum.all?(fn {sx, sy} ->
          Map.get(grid, {sx + x, sy + y}) == "#"
        end)
        |> if do
          {num + 1,
           Enum.reduce(sea_monster, acc_grid, fn {sx, sy}, a ->
             Map.put(a, {sx + x, sy + y}, "O")
           end)}
        else
          acc
        end
      end)

    if num > 0 do
      transformed
    else
      grid
      |> rotate(90, r > 270)
      |> hunt(sea_monster, r + 90)
    end
  end

  def build_grid(dimensions, corners, tiles) do
    dimensions
    |> do_build_grid(corners, tiles)
    |> Enum.reduce(%{}, fn {{x, y}, tile}, acc ->
      transformed =
        tile
        |> Enum.reject(fn {{tx, ty}, _cell} ->
          tx in [0, 9] or ty in [0, 9]
        end)
        |> Enum.map(fn {{tx, ty}, cell} ->
          {{tx + (x - 1) * 8, ty + (y - 1) * 8}, cell}
        end)
        |> Map.new()

      Map.merge(acc, transformed)
    end)
  end

  def find_start(tile, tiles) do
    edges =
      tiles
      |> Map.new(fn {key, t} ->
        {key, Enum.map([:top, :right, :bottom, :left], &get_edge(t, &1))}
      end)

    do_find_start(tile, edges)
  end

  def do_find_start(tile, edges) do
    [:left, :top]
    |> Enum.map(&get_edge(tile, &1))
    |> Enum.any?(&border?(&1, edges))
    |> if do
      rotate(tile, 90, false)
    else
      tile
    end
  end

  def do_build_grid(dimensions, corners, tiles, grid \\ %{}, x_size \\ 1, y_size \\ 1)

  def do_build_grid(dimensions, [h | rest] = _corners, tiles, grid, 1, 1) do
    {tile, tiles} = Map.pop(tiles, h)
    rotated = find_start(tile, tiles)
    grid = Map.put(grid, {1, 1}, rotated)
    do_build_grid(dimensions, rest, tiles, grid, 1, 2)
  end

  def do_build_grid(dimensions, corners, tiles, grid, x_size, y_size) do
    tiles_to_check =
      if {x_size, y_size} in [{1, dimensions}, {dimensions, dimensions}, {dimensions, 1}] do
        Map.take(tiles, corners)
      else
        Map.drop(tiles, corners)
      end

    {above, left} = get_surrounding_tiles(grid, {x_size, y_size})
    {tile_id, tile} = find_matching_edge(tiles_to_check, above, left)
    grid = Map.put(grid, {x_size, y_size}, tile)
    tiles = Map.delete(tiles, tile_id)
    corners = corners -- [tile_id]

    case {x_size, y_size} do
      {^dimensions, ^dimensions} -> grid
      {_, ^dimensions} -> do_build_grid(dimensions, corners, tiles, grid, x_size + 1, 1)
      {_, _} -> do_build_grid(dimensions, corners, tiles, grid, x_size, y_size + 1)
    end
  end

  def find_matching_edge(tiles, above, left) do
    Enum.find_value(tiles, fn {tile_id, tile} ->
      for deg <- 0..3, flipped <- [false, true] do
        {deg, flipped}
      end
      |> Enum.find_value(fn {deg, flipped} ->
        rotated = tile |> rotate(deg * 90, flipped)

        if (is_nil(above) or match_top(rotated, above)) and
             (is_nil(left) or match_left(rotated, left)) do
          {tile_id, rotated}
        end
      end)
    end)
  end

  def match_top(tile, above), do: get_edge(tile, :top) == get_edge(above, :bottom)
  def match_left(tile, left), do: get_edge(tile, :left) == get_edge(left, :right)

  def get_edge(tile, side) do
    tile
    |> Enum.filter(fn {{x, y}, _cell} ->
      case side do
        :top -> x == 0
        :right -> y == 9
        :bottom -> x == 9
        :left -> y == 0
      end
    end)
    |> Enum.sort()
    |> Enum.map(&elem(&1, 1))
    |> Enum.join()
  end

  # (−(𝑦−𝑏)+𝑎,(𝑥−𝑎)+𝑏)
  def rotate(tile, 0, false), do: tile

  def rotate(tile, degree, false) do
    d = tile |> map_size() |> :math.sqrt() |> floor()

    tile
    |> Map.new(fn {{x, y}, cell} ->
      {{-y + (d - 1), x}, cell}
    end)
    |> rotate(degree - 90, false)
  end

  def rotate(tile, degree, true) do
    d = tile |> map_size() |> :math.sqrt() |> floor()

    tile
    |> Map.new(fn {{x, y}, cell} ->
      {{abs(x - (d - 1)), y}, cell}
    end)
    |> rotate(degree, false)
  end

  def get_surrounding_tiles(grid, {x, y}) do
    left = grid |> Map.get({x, y - 1})
    above = grid |> Map.get({x - 1, y})
    {above, left}
  end

  def get_edges(tiles) do
    Map.new(tiles, fn {tile_id, tile} ->
      [left_edge, right_edge] =
        tile
        |> List.foldr(
          [[], []],
          fn row, [a, b] -> [[String.first(row) | a], [String.last(row) | b]] end
        )
        |> Enum.map(&Enum.join/1)

      {tile_id, [List.first(tile), right_edge, List.last(tile), left_edge]}
    end)
  end

  def border?(edge, other_tiles) do
    edges =
      other_tiles
      |> Map.values()
      |> Enum.reduce(MapSet.new(), fn tile_edges, set ->
        Enum.reduce(tile_edges, set, &MapSet.put(&2, &1))
      end)

    not MapSet.member?(edges, edge) and not MapSet.member?(edges, String.reverse(edge))
  end

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Map.new(fn chunk ->
      [<<"Tile ", id::binary-size(4), ":">> | grid] = String.split(chunk, "\n", trim: true)

      {String.to_integer(id), grid}
    end)
  end
end
