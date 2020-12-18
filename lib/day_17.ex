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
  def solve_part_3(input), do: do_solve(input, 5)

  def do_solve(input, dimensions) do
    input
    |> parse(dimensions)
    |> evolve()
    |> MapSet.size()
  end

  def evolve(state, evolutions \\ 1) do
    next_state =
      state
      |> Enum.flat_map(&find_neighbors/1)
      |> MapSet.new()
      |> Enum.reduce(MapSet.new(), fn point, acc ->
        case evolve_cube(point, state) do
          "#" -> MapSet.put(acc, point)
          _ -> acc
        end
      end)

    if evolutions == @evolutions do
      next_state
    else
      evolve(next_state, evolutions + 1)
    end
  end

  def evolve_cube(point, state) do
    active? = MapSet.member?(state, point)

    point
    |> find_neighbors()
    |> Kernel.--([point])
    |> Enum.filter(&MapSet.member?(state, &1))
    |> length()
    |> case do
      length when length in 2..3 and active? -> "#"
      3 -> "#"
      _ -> "."
    end
  end

  def find_neighbors(point), do: point |> Enum.map(fn d -> (d - 1)..(d + 1) end) |> find_points()

  def find_points([a | [b | rest]]) do
    new_a = for d1 <- a, d2 <- b, do: Enum.concat(List.wrap(d1), List.wrap(d2))

    if Enum.empty?(rest) do
      new_a
    else
      find_points([new_a | rest])
    end
  end

  def parse(input, dimensions) do
    pad = Stream.cycle([0]) |> Enum.take(dimensions - 2)

    input
    |> String.split("\n", trim: true)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, y_index}, acc ->
      line
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {cell, x_index}, inner_acc ->
        case cell do
          "#" -> MapSet.put(inner_acc, [x_index, y_index | pad])
          _ -> inner_acc
        end
      end)
    end)
  end
end
