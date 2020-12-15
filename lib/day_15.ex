defmodule Day15 do
  def test_input_1, do: "0,3,6"
  def test_input_2, do: "1,3,2"
  def test_input_3, do: "2,1,3"
  def test_input_4, do: "1,2,3"
  def test_input_5, do: "2,3,1"
  def test_input_6, do: "3,2,1"
  def test_input_7, do: "3,1,2"

  def solve_part_1(input), do: solve(input, 2020)
  def solve_part_2(input), do: solve(input, 30_000_000)

  def solve(input, total_iterations) do
    numbers = input |> parse()
    acc_map = numbers |> Enum.with_index(1) |> Map.new(fn {num, index} -> {num, {index, nil}} end)
    last_number = List.last(numbers)

    do_solve(last_number, acc_map, length(numbers) + 1, total_iterations)
  end

  def do_solve(last_number, acc_map, iteration, total_iterations) do
    prev_iteration = iteration - 1

    next_number =
      case Map.get(acc_map, last_number) do
        {^prev_iteration, nil} -> 0
        {^prev_iteration, used_at} -> prev_iteration - used_at
      end

    if iteration == total_iterations do
      next_number
    else
      new_acc_map =
        Map.update(acc_map, next_number, {iteration, nil}, fn {i, _} -> {iteration, i} end)

      do_solve(next_number, new_acc_map, iteration + 1, total_iterations)
    end
  end

  def parse(input) do
    input
    |> String.split(",", trin: true)
    |> Enum.map(&String.to_integer/1)
  end
end

10_800_000
