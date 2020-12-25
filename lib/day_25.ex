defmodule Day25 do
  def test_input do
    """
    5764801
    17807724
    """
  end

  @divisor 20_201_227

  def solve_part_1(input) do
    input
    |> parse()
    |> Enum.sort()
    |> find_loop_number()
    |> find_encryption_key()
  end

  def find_encryption_key({key, loop}), do: transform(1, key, loop)

  def find_loop_number([key_1, key_2] = keys, value \\ 1, loop \\ 1) do
    transformed = transform(value, 7, 1)

    case transformed do
      ^key_1 -> {key_2, loop}
      ^key_2 -> {key_1, loop}
      _ -> find_loop_number(keys, transformed, loop + 1)
    end
  end

  def transform(value, _subject_number, 0), do: value

  def transform(value, subject_number, loops) do
    value
    |> Kernel.*(subject_number)
    |> rem(@divisor)
    |> transform(subject_number, loops - 1)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
