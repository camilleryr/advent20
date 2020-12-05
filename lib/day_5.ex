defmodule Day5 do
  @front ?F
  @back ?B
  @left ?L
  @right ?R

  def test_input do
    """
    BFFFBBFRRR
    FFFBBBFRRR
    BBFFBBFRLL
    """
  end

  def solve_part_1(input) do
    input
    |> parse()
    |> Enum.max()
  end

  def solve_part_2(input) do
    tickets = MapSet.new(parse(input))
    all = MapSet.new(0..(127 * 8 + 7))
    unused = MapSet.difference(all, tickets)

    Enum.reduce_while(unused, tickets, fn seat, t ->
      if MapSet.member?(t, seat - 1) and MapSet.member?(t, seat + 1) do
        {:halt, seat}
      else
        {:cont, t}
      end
    end)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn <<l1, l2, l3, l4, l5, l6, l7, h1, h2, h3>> ->
      x = find_index(0..127, [l1, l2, l3, l4, l5, l6, l7], @front, @back)
      y = find_index(0..7, [h1, h2, h3], @left, @right)

      x * 8 + y
    end)
  end

  def find_index(range, codes, upper, lower) do
    Enum.reduce(codes, range, fn code, set ->
      {u, l} = Enum.split(set, div(Enum.count(set), 2))

      case code do
        ^upper -> u
        ^lower -> l
      end
    end)
    |> List.first()
  end
end
