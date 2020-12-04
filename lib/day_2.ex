defmodule Day2 do
  def test_input do
    """
    1-3 a: abcde
    1-3 b: cdefg
    2-9 c: ccccccccc
    """
  end

  def solve_part_1(input) do
    input
    |> parse
    |> Enum.count(&find_good_passwords/1)
  end

  def find_good_passwords({min, max, letter, password}) do
    password
    |> Enum.count(fn x -> x == letter end)
    |> inside(min..max)
  end

  def inside(length, range), do: length in range

  def solve_part_2(input) do
    input
    |> parse
    |> Enum.reduce(0, &find_good_passwords_2/2)
  end

  def find_good_passwords_2({min, max, letter, password}, acc) do
    if correct_position(password, min, letter) != correct_position(password, max, letter) do
      acc + 1
    else
      acc
    end
  end

  def correct_position(password, one_indexed_position, letter) do
    Enum.at(password, one_indexed_position - 1) == letter
  end

  def parse(input) do
    input
    |> to_charlist()
    |> :erl_scan.string(1, [:text])
    |> elem(1)
    |> Enum.chunk_every(6)
    |> Enum.map(fn [a, _, b, c, _, d] ->
      {
        elem(a, 2),
        elem(b, 2),
        List.first(elem(c, 1)[:text]),
        elem(d, 1)[:text]
      }
    end)
  end
end
