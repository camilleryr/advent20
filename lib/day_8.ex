defmodule Day8 do
  def test_input do
    """
    nop +0
    acc +1
    jmp +4
    acc +3
    jmp -3
    acc -99
    acc +1
    jmp -4
    acc +6
    """
  end

  def solve_part_1(input) do
    input
    |> parse()
    |> do_solve_part_1()
  end

  def do_solve_part_1(
        instructions,
        {current_position, _accumulator} = buffer \\ {0, 0},
        history \\ MapSet.new([0])
      ) do
    {new_position, new_acc} =
      new_buffer =
      current_position
      |> :array.get(instructions)
      |> execute_instruction(buffer)

    if MapSet.member?(history, new_position) do
      new_acc
    else
      do_solve_part_1(instructions, new_buffer, MapSet.put(history, new_position))
    end
  end

  def solve_part_2(input) do
    instructions = parse(input)

    do_solve_part_2(instructions, :array.size(instructions) - 1)
  end

  def do_solve_part_2(original_instructions, position_to_change) do
    position_to_change
    |> :array.get(original_instructions)
    |> case do
      {:acc, _arg} ->
        nil

      {inst, arg} ->
        position_to_change
        |> :array.set({flip(inst), arg}, original_instructions)
        |> do_solve_part_2({0, 0}, MapSet.new([0]))
    end
    |> case do
      value when not is_nil(value) -> value
      nil -> do_solve_part_2(original_instructions, position_to_change - 1)
    end
  end

  def do_solve_part_2(instructions, {current_position, _accumulator} = buffer, history) do
    {new_position, new_acc} =
      new_buffer =
      current_position
      |> :array.get(instructions)
      |> execute_instruction(buffer)

    cond do
      new_position >= :array.size(instructions) ->
        new_acc

      MapSet.member?(history, new_position) ->
        nil

      true ->
        do_solve_part_2(instructions, new_buffer, MapSet.put(history, new_position))
    end
  end

  def flip(:jmp), do: :nop
  def flip(:nop), do: :jmp

  def execute_instruction({inst, arg} = _instruction, {current_position, accumulator} = _buffer) do
    case inst do
      :nop -> {current_position + 1, accumulator}
      :acc -> {current_position + 1, accumulator + arg}
      :jmp -> {current_position + arg, accumulator}
    end
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn <<inst::binary-size(3), " ", arg::binary>> ->
      {String.to_atom(inst), String.to_integer(arg)}
    end)
    |> :array.from_list()
    |> :array.fix()
  end
end
