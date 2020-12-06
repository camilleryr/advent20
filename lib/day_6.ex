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
    |> parse()
    |> Enum.reduce(0, fn group, total ->
      group
      |> Enum.reduce(&reducer.(&1, &2))
      |> MapSet.size()
      |> Kernel.+(total)
    end)
  end

  def parse(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(fn line ->
      line
      |> String.split("\n", trim: true)
      |> Enum.map(fn l -> l |> String.split("", trim: true) |> MapSet.new() end)
    end)
  end
end
