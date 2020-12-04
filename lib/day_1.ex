defmodule Day1 do
  def test_input do
    """
    1721
    979
    366
    299
    675
    1456
    """
  end

  def solve_part_1(input) do
    input
    |> numbers()
    |> find_solution()
  end

  defp find_solution([h | tail]) do
    tail
    |> Enum.find_value(&if &1 + h == 2020, do: &1 * h)
    |> case do
      value when not is_nil(value) -> value
      nil -> find_solution(tail)
    end
  end

  def solve_part_2(input) do
    input
    |> numbers()
    |> Enum.sort()
    |> do_solve_part_2()
  end

  def do_solve_part_2([_h1 | [h2, h3, h4 | _tail_2] = tail] = list) do
    x = h2 + h3 + h4

    cond do
      x == 2020 -> h2 * h3 * h4
      x > 2020 -> find_solution_2(list)
      true -> do_solve_part_2(tail)
    end
  end

  def find_solution_2([h | t]) do
    case find_solution_2(h, t) do
      value when not is_nil(value) -> value
      nil -> find_solution_2(t)
    end
  end

  def find_solution_2(h1, list) do
    case list do
      [h2 | tail] ->
        case find_solution_2(h1, h2, tail) do
          value when not is_nil(value) -> value
          nil -> find_solution_2(h1, tail)
        end

      [] ->
        nil
    end
  end

  def find_solution_2(h1, h2, list) do
    case list do
      [h3 | tail] ->
        x = h1 + h2 + h3

        cond do
          x < 2020 -> find_solution_2(h1, h2, tail)
          x == 2020 -> h1 * h2 * h3
          x > 2020 -> nil
        end

      [] ->
        nil
    end
  end

  defp numbers(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
  end
end
