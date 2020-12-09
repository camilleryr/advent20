defmodule Day9 do
  def test_input do
    """
    35
    20
    15
    25
    47
    40
    62
    55
    65
    95
    102
    117
    150
    182
    127
    219
    299
    277
    309
    576
    """
  end

  @solution_preamble 25
  @part_1_solution 26134589

  def solve_part_1(input, preable_length \\ @solution_preamble) do
    input
    |> parse
    |> Stream.chunk_every(preable_length + 1, 1)
    |> Stream.map(&Enum.reverse/1)
    |> Enum.find_value(fn [to_find | chunk] ->
      chunk
      |> Enum.reject(& &1 >= to_find)
      |> find_sums(to_find)
    end)
  end

  def find_sums([], to_check), do: to_check

  def find_sums([h | t] = _preable_set, to_find) do
    Enum.reduce_while(t, nil, fn el, _acc ->
      if h + el == to_find do
        {:halt, :match}
      else
        {:cont, nil}
      end
    end)
    |> case do
      :match -> nil
      nil -> find_sums(t, to_find)
    end
  end

  def solve_part_2(input, invalid_number \\ @part_1_solution) do
    input
    |> parse
    |> do_solve_part_2(invalid_number)
  end

  def do_solve_part_2([_h | t] = numbers, invalid_number) do
    numbers
    |> Enum.reduce_while({0, nil, 0}, fn el, {acc, min_el, max_el} ->
      case el + acc do
        ^invalid_number ->
          {:halt, min_el + max_el}

        val when val > invalid_number ->
          {:halt, nil}

        val when val < invalid_number ->
          {:cont, {val, min(min_el, el), max(max_el, el)}}
      end
    end)
    |> case do
      val when is_number(val) -> val
      nil -> do_solve_part_2(t, invalid_number)
    end
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
