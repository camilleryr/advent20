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

    [{1, index}] = :ets.lookup(__MODULE__, 1)

    :ets.select(__MODULE__, [
      {{:_, :"$1"}, [{:andalso, {:>=, :"$1", index + 1}, {:"=<", :"$1", index + 2}}], [:"$_"]}
    ])
    |> Enum.reduce(1, fn {num, _dix}, acc -> acc * num end)
  end

  def crab_shuffle(enum, generations) when is_list(enum) do
    __MODULE__
    |> :ets.new([:public, :named_table, :set])
    |> :ets.insert(enum |> Enum.with_index(1))

    do_crab_shuffle(1, generations, length(enum))
  end

  def do_crab_shuffle(_, 0, _ls), do: :ok

  def do_crab_shuffle(current_index, generations, list_size) do
    :ets.select(__MODULE__, [{:"$1", [], [:"$_"]}])
    |> Enum.sort_by(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))

    ms = to_ms(current_index, 4, list_size)

    [{current_num, ^current_index} | removed] =
      __MODULE__
      |> :ets.select(ms)
      |> Enum.sort_by(fn {_n, idx} ->
        if idx >= current_index do
          idx
        else
          list_size + idx
        end
      end)

    destination =
      (current_num - 1)
      |> find_destination(removed, list_size)

    [{^destination, destination_index}] = :ets.lookup(__MODULE__, destination)

    # (removed d+1-3), ((dest + 1 -> curret) + 3)
    # ((curret + 4 -> destination) - 3), (removed d+1-3)
    current_index
    |> find_distances(destination_index, list_size)
    |> case do
      {l_dist, r_dist} when l_dist >= r_dist - 4 ->
        to_insert =
          :ets.select(
            __MODULE__,
            to_ms(next(current_index + 3, list_size), r_dist - 3, list_size)
          )
          |> Enum.sort_by(fn {_n, idx} ->
            if idx >= current_index do
              idx
            else
              list_size + idx
            end
          end)
          |> Enum.concat(removed)
          |> Enum.with_index()
          |> Enum.map(fn {{number, _old_idx}, chunk_index} ->
            {number, next(current_index + chunk_index, list_size)}
          end)

        :ets.insert(__MODULE__, to_insert)

      {l_dist, _r_dist} ->
        to_insert =
          :ets.select(__MODULE__, to_ms(next(destination_index, list_size), l_dist, list_size))
          |> Enum.sort_by(fn {_n, idx} ->
            if idx >= destination_index do
              idx
            else
              list_size + idx
            end
          end)
          |> (&Enum.concat(removed, &1)).()
          |> Enum.with_index()
          |> Enum.map(fn {{number, _old_idx}, chunk_index} ->
            {number, next(destination_index + chunk_index, list_size)}
          end)

        :ets.insert(__MODULE__, to_insert)
    end

    [{^current_num, current_num_new_index}] = :ets.lookup(__MODULE__, current_num)

    current_num_new_index
    |> next(list_size)
    |> do_crab_shuffle(generations - 1, list_size)
  end

  def next(i, list_size) do
    if i > list_size - 1 do
      next(i - list_size, list_size)
    else
      i + 1
    end
  end

  def find_distances(current_index, destination_index, list_size)
      when current_index < destination_index do
    {list_size - destination_index + current_index, destination_index - current_index}
  end

  def find_distances(current_index, destination_index, list_size) do
    {current_index - destination_index, list_size - current_index + destination_index}
  end

  def to_ms(index, n, list_size) when is_integer(index) and index <= list_size - (n - 1) do
    [{{:_, :"$1"}, [{:andalso, {:>=, :"$1", index}, {:"=<", :"$1", index + (n - 1)}}], [:"$_"]}]
  end

  def to_ms(index, n, list_size) when is_integer(index) do
    [
      {{:_, :"$1"},
       [{:orelse, {:>=, :"$1", index}, {:"=<", :"$1", next(index + (n - 2), list_size)}}],
       [:"$_"]}
    ]
  end

  def find_destination(0, removed, list_size), do: find_destination(list_size, removed, list_size)

  def find_destination(dest, [{x1, _}, {x2, _}, {x3, _}] = removed, list_size) do
    if dest != x1 and dest != x2 and dest != x3 do
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
