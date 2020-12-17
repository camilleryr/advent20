defmodule Day17 do
  def test_input do
    """
    .#.
    ..#
    ###
    """
  end

  @evolutions 6

  def solve_part_1(input), do: do_solve(input, 3)
  def solve_part_2(input), do: do_solve(input, 4)

  def do_solve(input, dimensions) do
    input
    |> parse(dimensions)
    |> evolve()
    |> count_active()
  end

  def count_active(state) do
    state
    |> Map.values()
    |> Enum.filter(fn cell -> cell == "#" end)
    |> Enum.count()
  end

  def evolve({state, initial_size}, evolutions \\ 1), do: evolve(state, initial_size, evolutions)

  def evolve(state, initial_size, evolutions) do
    next_state =
      initial_size
      |> Enum.map(fn max -> (0-evolutions)..(max+evolutions) end)
      |> find_points()
      |> Map.new(fn point -> {point, evolve_cube(point, state)} end)

    if evolutions == @evolutions do
      next_state
    else
      evolve(next_state, initial_size, evolutions + 1)
    end
  end

  def find_points([a | [b | rest]]) do
    new_a = for d1 <- a, d2 <- b, do: Enum.concat(List.wrap(d1), List.wrap(d2))

    if Enum.empty?(rest) do
      new_a
    else
      find_points([new_a | rest])
    end
  end

  def evolve_cube(point, state) do
    current_state = Map.get(state, point, ".")

    point
    |> Enum.map(fn d -> (d - 1)..(d + 1) end)
    |> find_points()
    |> Kernel.--([point])
    |> Enum.map(fn neighbor -> Map.get(state, neighbor, ".") end)
    |> Enum.frequencies()
    |> do_evolve(current_state)
  end

  def do_evolve(%{"#" => freq}, "#") when freq in 2..3, do: "#"
  def do_evolve(%{"#" => 3}, "."), do: "#"
  def do_evolve(_neighbor_states, _), do: "."

  def parse(input, dimensions) do
    pad = Stream.cycle([0]) |> Enum.take(dimensions - 2)

    initial_state =
      input
      |> String.split("\n", trim: true)
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y_index}, acc ->
        line
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {cell, x_index}, inner_acc ->
          Map.put(inner_acc, [x_index, y_index | pad], cell)
        end)
      end)

    max_x = initial_state |> Map.keys() |> Enum.map(&Enum.at(&1, 0)) |> Enum.max()
    max_y = initial_state |> Map.keys() |> Enum.map(&Enum.at(&1, 1)) |> Enum.max()

    {initial_state, [max_x, max_y | pad]}
  end
end
