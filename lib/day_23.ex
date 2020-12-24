defmodule Day23 do
  def test_input, do: "389125467"

  def solve_part_1(input) do
    input
    |> parse()
    |> crab_shuffle(100)

    {head, [1 | tail]} =
      :ets.select(__MODULE__, [{:"$1", [], [:"$_"]}])
      |> Enum.sort_by(&elem(&1, 1))
      |> Enum.map(&elem(&1, 0))
      |> Enum.split_while(&(&1 != 1))

    tail
    |> Enum.concat(head)
    |> Enum.join()
  end

  def solve_part_2(input) do
    input
    |> parse()
    |> Enum.concat(10..1_000_000)
    |> crab_shuffle(10_000_000)

    [{1, n1}] = :ets.lookup(__MODULE__, 1)
    [{^n1, n2}] = :ets.lookup(__MODULE__, n1)

    n1 * n2
  end

  def crab_shuffle([h | t] = enum, generations) when is_list(enum) do
    __MODULE__
    |> :ets.new([:public, :named_table, :set])
    |> :ets.insert(Enum.zip(enum, t ++ [h]))

    do_crab_shuffle(h, generations, length(enum))
  end

  def do_crab_shuffle(_, 0, _ls), do: :ok

  def do_crab_shuffle(current_cup, generations, size) do
    [{^current_cup, n1}] = :ets.lookup(__MODULE__, current_cup)
    [{^n1, n2}] = :ets.lookup(__MODULE__, n1)
    [{^n2, n3}] = :ets.lookup(__MODULE__, n2)
    [{^n3, next_cup}] = :ets.lookup(__MODULE__, n3)

    destination = find_destination(current_cup - 1, [n1, n2, n3], size)
    [{^destination, after_destination}] = :ets.lookup(__MODULE__, destination)

    :ets.insert(__MODULE__, [
      {current_cup, next_cup},
      {destination, n1},
      {n3, after_destination}
    ])

    do_crab_shuffle(next_cup, generations - 1, size)
  end

  def find_destination(0, removed, list_size), do: find_destination(list_size, removed, list_size)

  def find_destination(dest, [n1, n2, n3] = removed, list_size) do
    if dest != n1 and dest != n2 and dest != n3 do
      dest
    else
      find_destination(dest - 1, removed, list_size)
    end
  end

  def parse(input) do
    input
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end
end
