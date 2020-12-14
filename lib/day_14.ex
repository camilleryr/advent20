defmodule Day14 do
  def test_input do
    """
    mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
    mem[8] = 11
    mem[7] = 101
    mem[8] = 0
    """
  end

  def solve_part_1(input) do
    input
    |> parse
    |> Enum.reduce(%{}, fn {mask, instructions}, memory ->
      Enum.reduce(instructions, memory, fn {address, assignment}, memory ->
        Map.put(memory, address, apply_mask(assignment, mask))
      end)
    end)
    |> Enum.reduce(0, fn {_addres, value}, acc -> acc + value end)
  end

  def apply_mask(number, mask) when is_integer(number) do
    number
    |> Integer.to_string(2)
    |> String.pad_leading(36, "0")
    |> apply_mask(mask)
  end

  def apply_mask(binary, mask) do
    0..35
    |> Enum.map(fn i ->
      case String.at(mask, i) do
        "X" -> String.at(binary, i)
        other -> other
      end
    end)
    |> Enum.join()
    |> String.to_integer(2)
  end

  def test_input_2 do
    """
    mask = 000000000000000000000000000000X1001X
    mem[42] = 100
    mask = 00000000000000000000000000000000X0XX
    mem[26] = 1
    """
  end

  def solve_part_2(input) do
    input
    |> parse
    |> Enum.reduce(%{}, fn {mask, instructions}, memory ->
      Enum.reduce(instructions, memory, fn {address, assignment}, memory ->
        new_assignments =
          address
          |> apply_mask_2(mask)
          |> Map.new(fn add -> {add, assignment} end)

        Map.merge(memory, new_assignments)
      end)
    end)
    |> Enum.reduce(0, fn {_addres, value}, acc -> acc + value end)
  end

  def apply_mask_2(number, mask) when is_integer(number) do
    number
    |> Integer.to_string(2)
    |> String.pad_leading(36, "0")
    |> apply_mask_2(mask)
  end

  def apply_mask_2(binary, mask) do
    35..0
    |> Enum.reduce([[]], fn i, acc ->
      case String.at(mask, i) do
        "0" ->
          Enum.map(acc, fn l -> [String.at(binary, i) | l] end)

        "1" ->
          Enum.map(acc, fn l -> ["1" | l] end)

        "X" ->
          Enum.concat(Enum.map(acc, fn l -> ["0" | l] end), Enum.map(acc, fn l -> ["1" | l] end))
      end
    end)
    |> Enum.map(fn l -> l |> Enum.join() |> String.to_integer(2) end)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce([], fn
      <<"mask = ", mask::binary>>, acc ->
        [{mask, []} | acc]

      mem_line, [{mask, instructions} | t] ->
        [address, assignment] = String.split(mem_line, ~r/(mem\[|\] = )/, trim: true)

        [
          {mask, [{String.to_integer(address), String.to_integer(assignment)} | instructions]}
          | t
        ]
    end)
    |> Enum.reduce([], fn {mask, instructions}, acc ->
      [{mask, Enum.reverse(instructions)} | acc]
    end)
  end
end
