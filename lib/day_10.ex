defmodule Day10 do
  def test_input do
    """
    16
    10
    15
    5
    1
    11
    7
    19
    6
    12
    4
    """
  end

  def test_input_2 do
    """
    28
    33
    18
    42
    31
    14
    46
    20
    48
    47
    24
    23
    49
    45
    19
    38
    39
    11
    1
    32
    25
    35
    8
    17
    7
    9
    4
    2
    34
    10
    3
    """
  end

  def solve_part_1(input) do
    {_, ones, threes} =
      input
      |> parse
      |> Enum.reduce({0, 0, 0}, fn el, {prev, ones, threes} = acc ->
        case el - prev do
          1 -> {el, ones + 1, threes}
          3 -> {el, ones, threes + 1}
          _ -> acc
        end
      end)

    ones * (threes + 1)
  end

  def solve_part_2(input) do
    input
    |> parse()
    |> find_consecutives()
    |> Enum.map(&to_perm/1)
    |> Enum.reduce(&Kernel.*/2)
  end

  def find_consecutives(list) do
    {return, _} =
      Enum.reduce(list, {[1], 0}, fn el, {[h | t] = l, prev} ->
        if el - prev == 1 do
          {[h + 1 | t], el}
        else
          {[1 | l], el}
        end
      end)

    return
  end

  def to_perm(1), do: 1
  def to_perm(n), do: to_perm(n - 1) + n - 2

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()
  end
end
