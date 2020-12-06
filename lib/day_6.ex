defmodule Day6 do
  def test_input do
    """
    abc

    a
    b
    c

    ab
    ac

    a
    a
    a
    a

    b
    """
  end

  def solve_part_1(input) do
    do_solve(input, &MapSet.union/2)
  end

  def solve_part_2(input) do
    do_solve(input, &MapSet.intersection/2)
  end

  def do_solve(input, reducer) do
    input
    |> String.split("\n\n")
    |> get_total(reducer)
  end

  def get_total(enum, reducer) do
    enum
    |> Enum.reduce(0, fn line, total ->
      line
      |> String.split("\n", trim: true)
      |> reduce(reducer)
      |> MapSet.size()
      |> Kernel.+(total)
    end)
  end

  def reduce(enum, reducer) do
    enum
    |> Enum.reduce(nil, fn l, acc ->
      new =
        l
        |> String.split("", trim: true)
        |> MapSet.new()

      case acc do
        %MapSet{} -> reducer.(acc, new)
        nil -> new
      end
    end)
  end
end
