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
    input
    |> parse()
    |> Enum.reduce(0, fn group, total ->
      group
      |> Enum.join()
      |> String.graphemes()
      |> Enum.uniq()
      |> length()
      |> Kernel.+(total)
    end)
  end

  def solve_part_2(input) do
    input
    |> parse()
    |> Enum.reduce(0, fn group, total ->
      group
      |> Enum.map(fn g -> g |> String.graphemes() |> MapSet.new() end)
      |> Enum.reduce(&MapSet.intersection/2)
      |> MapSet.size()
      |> Kernel.+(total)
    end)
  end

  def parse(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&String.split(&1, "\n", trim: true))
  end
end

