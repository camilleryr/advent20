defmodule Day13 do
  def test_input do
    """
    939
    7,13,x,x,59,x,31,19
    """
  end

  # 3417
  def test_input_2 do
    """
    939
    17,x,13,19
    """
  end

  # 754018
  def test_input_3 do
    """
    939
    67,7,59,61
    """
  end

  # 779210
  def test_input_4 do
    """
    939
    67,x,7,59,61
    """
  end

  # 1261476
  def test_input_5 do
    """
    939
    67,7,x,59,61
    """
  end

  # 1202161486
  def test_input_6 do
    """
    939
    1789,37,47,1889
    """
  end

  def solve_part_1(input) do
    {timestamp, busses} = parse(input)

    {bus_id, arrives_at} =
      busses
      |> Enum.filter(& &1)
      |> Enum.map(fn bus_id -> {bus_id, timestamp + (bus_id - rem(timestamp, bus_id))} end)
      |> IO.inspect()
      |> Enum.min_by(fn {_bus_id, arrives_at} -> arrives_at end)

    (arrives_at - timestamp) * bus_id
  end

  def solve_part_2(input) do
    input
    |> parse()
    |> elem(1)
    |> Enum.with_index()
    |> Enum.filter(&elem(&1, 0))
    |> Enum.reduce({0, 1}, fn {bus, index}, {t, step} ->
      t =
        Stream.unfold(t, fn t -> {t, t + step} end)
        |> Stream.filter(fn t -> rem(t + index, bus) == 0 end)
        |> Enum.at(0)

      {t, lcm(step, bus)}
    end)
    |> elem(1)
  end

  def lcm(a, b) do
    div(a * b, Integer.gcd(a, b))
  end

  def parse(input) do
    [timestamp, string] = input |> String.split("\n", trim: true)

    busses =
      string
      |> String.split(",", trim: true)
      |> Enum.map(fn
        "x" -> nil
        id -> String.to_integer(id)
      end)

    {String.to_integer(timestamp), busses}
  end
end
