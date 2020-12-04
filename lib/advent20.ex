defmodule Advent20 do
  @doc """
  Solve a puzzle for a given day.
  Calls the `solve/1` function on the `DayN` module using the input from the
  `inputs/day_n.txt` file.
  """
  def solve(day, part) do
    input = read_input(day)
    module = day_module(day)
    function = part_func(part)

    apply(module, function, [input])
  end

  def read_input(day) do
    "input/day_#{day}.txt"
    |> File.read!()
    |> String.trim()
  end

  defp day_module(day), do: String.to_atom("Elixir.Day#{day}")
  defp part_func(part), do: String.to_atom("solve_part_#{part}")
end
