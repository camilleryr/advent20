defmodule BasicMath do
  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: a * b / gcd(a, b)
end

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
      |> Enum.min_by(fn {_bus_id, arrives_at} -> arrives_at end)

    (arrives_at - timestamp) * bus_id
  end

  # based on the chinese remainder theorem
  # https://www.youtube.com/watch?v=zIFehsBHB8o
  def solve_part_2(input) do
    {_ts, busses} = parse(input)

    congruences =
      busses
      |> Enum.with_index()
      |> Enum.filter(fn {bus_id, _index} -> bus_id end)

    big_n =
      congruences
      |> Enum.map(&elem(&1, 0))
      |> Enum.reduce(&Kernel.*/2)

    congruences
    |> Enum.map(fn {mod, rem} ->
      bi = mod - rem
      ni = div(big_n, mod)
      xi = find_inverse(ni - div(ni, mod) * mod, mod)

      bi * ni * xi
    end)
    |> Enum.sum()
    |> rem(big_n)
  end

  def find_inverse(a, m, x \\ 1) do
    if rem(a * x, m) == 1 do
      x
    else
      find_inverse(a, m, x + 1)
    end
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
