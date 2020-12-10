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
    {_, ones, _, threes} =
      input
      |> parse
      |> Enum.reduce({0, 0, 0, 0}, fn el, {prev, ones, twos, threes} = acc ->
        case el - prev do
          1 -> {el, ones + 1, twos, threes}
          3 -> {el, ones, twos, threes + 1}
          _ -> acc
        end
      end)

    ones * (threes + 1)
  end

  def solve_part_2(input) do
    input
    |> parse()
    |> find_consecutives()
    |> Enum.map(&to_fib/1)
    |> Enum.chunk_by(& &1 == 1)
    |> Enum.map(&find_value/1)
    |> Enum.reduce(&Kernel.*/2)
  end

  def find_value([1 | _]), do: 1
  def find_value([h | t]) do
    h + length(t)
  end

  def find_consecutives([_]), do: [1]

  def find_consecutives([h | t]) do
    {count, _} =
      Enum.reduce_while(t, {1, h}, fn el, {count, prev} ->
        if el - prev == 1 do
          {:cont, {count + 1, el}}
        else
          {:halt, {count, el}}
        end
      end)

    [count | find_consecutives(t)]
  end

  def to_fib(n) when n in 0..2, do: 1
  def to_fib(n), do: to_fib(n - 1) + to_fib(n - 2)

  def parse(input) do
    i =
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()

    [0] ++ i
  end
end

