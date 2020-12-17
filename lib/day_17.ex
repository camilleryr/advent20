defmodule Day17 do
  def test_input do
    """
    .#.
    ..#
    ###
    """

    # {0, 2}, {1, 2}, {2, 2}
    # {0, 1}, {1, 1}, {2, 1}
    # {0, 0}, {1, 0}, {2, 0}
  end

  def solve_part_1(input) do
    input
    |> parse()
    |> evolve(6)
    |> count_active()
  end

  def solve_part_2(input) do
    input
    |> parse_2()
    |> evolve_2(6)
    |> count_active()
  end

  def count_active(state) do
    state
    |> Map.values()
    |> Enum.filter(fn cell -> cell == "#" end)
    |> Enum.count()
  end

  def evolve({state, _ranges}, 0), do: state

  def evolve({state, {min_x, max_x, min_y, max_y, min_z, max_z} = edges}, evolutions) do
    for x <- (min_x - 1)..(max_x + 1),
        y <- (min_y - 1)..(max_y + 1),
        z <- (min_z - 1)..(max_z + 1),
        reduce: {%{}, edges} do
      {next_state, {nx, xx, ny, xy, nz, xz}} ->
        point = {x, y, z}
        cube = evolve_cube(point, state)

        {Map.put(next_state, point, cube),
         {
           mn(cube, x, nx),
           mx(cube, x, xx),
           mn(cube, y, ny),
           mx(cube, y, xy),
           mn(cube, z, nz),
           mx(cube, z, xz)
         }}
    end
    |> evolve(evolutions - 1)
  end

  def evolve_cube({x, y, z} = p, state) do
    current_state = Map.get(state, p, ".")

    for xi <- (x - 1)..(x + 1),
        yi <- (y - 1)..(y + 1),
        zi <- (z - 1)..(z + 1),
        {xi, yi, zi} != p do
      Map.get(state, {xi, yi, zi}, ".")
    end
    |> Enum.frequencies()
    |> do_evolve(current_state)
  end

  ############################################################################
  ############################################################################
  def evolve_2({state, _ranges}, 0), do: state

  def evolve_2(
        {state, {min_x, max_x, min_y, max_y, min_z, max_z, min_w, max_w} = edges},
        evolutions
      ) do
    for x <- (min_x - 1)..(max_x + 1),
        y <- (min_y - 1)..(max_y + 1),
        z <- (min_z - 1)..(max_z + 1),
        w <- (min_w - 1)..(max_w + 1),
        reduce: {%{}, edges} do
      {next_state, {nx, xx, ny, xy, nz, xz, nw, xw}} ->
        point = {x, y, z, w}
        cube = evolve_cube_2(point, state)

        {Map.put(next_state, point, cube),
         {
           mn(cube, x, nx),
           mx(cube, x, xx),
           mn(cube, y, ny),
           mx(cube, y, xy),
           mn(cube, z, nz),
           mx(cube, z, xz),
           mn(cube, w, nw),
           mx(cube, w, xw)
         }}
    end
    |> evolve_2(evolutions - 1)
  end

  def evolve_cube_2({x, y, z, w} = p, state) do
    current_state = Map.get(state, p, ".")

    for xi <- (x - 1)..(x + 1),
        yi <- (y - 1)..(y + 1),
        zi <- (z - 1)..(z + 1),
        wi <- (w - 1)..(w + 1),
        {xi, yi, zi, wi} != p do
      Map.get(state, {xi, yi, zi, wi}, ".")
    end
    |> Enum.frequencies()
    |> do_evolve(current_state)
  end

  def parse_2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce({%{}, {0, 0, 0, 0, 0, 0, 0, 0}}, fn {line, y_index}, acc ->
      line
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {cell, x_index},
                             {inner_acc, {min_x, max_x, min_y, max_y, 0, 0, 0, 0}} ->
        {Map.put(inner_acc, {x_index, y_index, 0, 0}, cell),
         {
           mn(cell, x_index, min_x),
           mx(cell, x_index, max_x),
           mn(cell, y_index, min_y),
           mx(cell, y_index, max_y),
           0,
           0,
           0,
           0
         }}
      end)
    end)
  end

  def do_evolve(%{"#" => freq}, "#") when freq in 2..3, do: "#"
  def do_evolve(%{"#" => 3}, "."), do: "#"
  def do_evolve(_neighbor_states, _), do: "."

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce({%{}, {0, 0, 0, 0, 0, 0}}, fn {line, y_index}, acc ->
      line
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {cell, x_index}, {inner_acc, {min_x, max_x, min_y, max_y, 0, 0}} ->
        {Map.put(inner_acc, {x_index, y_index, 0}, cell),
         {
           mn(cell, x_index, min_x),
           mx(cell, x_index, max_x),
           mn(cell, y_index, min_y),
           mx(cell, y_index, max_y),
           0,
           0
         }}
      end)
    end)
  end

  def mx(c, a, b), do: edge(:max, c, a, b)
  def mn(c, a, b), do: edge(:min, c, a, b)

  def edge(:max, "#", a, b), do: max(a, b)
  def edge(:min, "#", a, b), do: min(a, b)
  def edge(_, _, _a, current), do: current
end
