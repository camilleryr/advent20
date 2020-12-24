defmodule Day24 do
  def test_input do
    """
    sesenwnenenewseeswwswswwnenewsewsw
    neeenesenwnwwswnenewnwwsewnenwseswesw
    seswneswswsenwwnwse
    nwnwneseeswswnenewneswwnewseswneseene
    swweswneswnenwsewnwneneseenw
    eesenwseswswnenwswnwnwsewwnwsene
    sewnenenenesenwsewnenwwwse
    wenwwweseeeweswwwnwwe
    wsweesenenewnwwnwsenewsenwwsesesenwne
    neeswseenwwswnwswswnw
    nenwswwsewswnenenewsenwsenwnesesenew
    enewnwewneswsewnwswenweswnenwsenwsw
    sweneswneswneneenwnewenewwneswswnese
    swwesenesewenwneswnwwneseswwne
    enesenwswwswneneswsenwnewswseenwsese
    wnwnesenesenenwwnenwsewesewsesesew
    nenewswnwewswnenesenwnesewesw
    eneswnwswnwsenenwnwnwwseeswneewsenese
    neswnwewnwnwseenwseesewsenwsweewe
    wseweeenwnesenwwwswnew
    """
  end

  def solve_part_1(input) do
    input
    |> parse()
    |> get_initial_floor_state()
    |> Enum.count(&find_black/1)
  end

  def solve_part_2(input) do
    input
    |> parse()
    |> get_initial_floor_state()
    |> Enum.filter(fn {_k, tile_color} -> tile_color == :black end)
    |> Enum.map(fn {key, _} -> key end)
    |> MapSet.new()
    |> evolve(100)
    |> MapSet.size()
  end

  def evolve(floor_state, 0), do: floor_state

  def evolve(floor_state, generations) do
    floor_state
    |> find_neighbors()
    |> Enum.filter(&do_evolve(&1, floor_state))
    |> MapSet.new()
    |> evolve(generations - 1)
  end

  def do_evolve(cord, floor_state) do
    cord
    |> find_neighbors()
    |> Enum.filter(&MapSet.member?(floor_state, &1))
    |> length()
    |> run_rules(MapSet.member?(floor_state, cord))
  end

  def run_rules(n, true) when n == 0 or n > 2, do: false
  def run_rules(2, false), do: true
  def run_rules(_, state), do: state

  def find_neighbors({x, y}) do
    [
      {x + 1, y + 0},
      {x + 1, y - 1},
      {x + 0, y + 1},
      {x + 0, y - 1},
      {x - 1, y + 1},
      {x - 1, y - 0}
    ]
  end

  def find_neighbors(floor_state) do
    Enum.flat_map(floor_state, fn cord -> find_neighbors(cord) end)
  end

  def get_initial_floor_state(directions_list) do
    Enum.reduce(directions_list, %{}, fn directions, floor ->
      Map.update(floor, find_destination(directions), :black, &flip_tile/1)
    end)
  end

  def flip_tile(:black), do: :white
  def flip_tile(:white), do: :black

  def find_black({_coord, tile_color}), do: tile_color == :black

  def find_destination(directions) do
    Enum.reduce(directions, {0, 0}, fn
      "e", {x, y} -> {x + 1, y}
      "w", {x, y} -> {x - 1, y}
      "ne", {x, y} -> {x, y + 1}
      "sw", {x, y} -> {x, y - 1}
      "se", {x, y} -> {x + 1, y - 1}
      "nw", {x, y} -> {x - 1, y + 1}
    end)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.replace(~w[e se sw w nw ne], fn direction -> direction <> " " end)
      |> String.split(" ", trim: true)
    end)
  end
end
