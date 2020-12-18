defmodule Day18 do
  def test_input_1 do
    """
    ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2
    """
  end

  def solve_part_1(input), do: do_solve(input, %{"+" => 1, "*" => 1})
  def solve_part_2(input), do: do_solve(input, %{"+" => 2, "*" => 1})

  def do_solve(input, operator_precedences) do
    input
    |> parse()
    |> Enum.map(&shunting_yard(&1, operator_precedences))
    |> Enum.map(&evaluate_reverse_polish/1)
    |> Enum.sum()
  end

  def evaluate_reverse_polish(rp_notation, stack \\ [])
  def evaluate_reverse_polish([value], _stack) when is_integer(value), do: value

  def evaluate_reverse_polish([head | rest] = _rp_notation, stack) do
    if is_integer(head) do
      evaluate_reverse_polish(rest, [head | stack])
    else
      [l, r | stack_rest] = stack
      evaluated = to_op_func(head).(l, r)
      evaluate_reverse_polish([evaluated | rest], stack_rest)
    end
  end

  def shunting_yard(expression, operator_precedences) do
    expression
    |> Enum.reduce({[], []}, fn token, {output_queue, operator_stack} ->
      case token do
        "(" ->
          {output_queue, ["(" | operator_stack]}

        ")" ->
          match_paren({output_queue, operator_stack})

        operator when operator in ["+", "*"] ->
          handle_operator(operator, {output_queue, operator_stack}, operator_precedences)

        int ->
          {[String.to_integer(int) | output_queue], operator_stack}
      end
    end)
    |> (fn {output_queue, operator_stack} -> Enum.reverse(output_queue) ++ operator_stack end).()
  end

  def match_paren({output_queue, ["(" | rest] = _operator_stack}), do: {output_queue, rest}

  def match_paren({output_queue, [head | rest] = _operator_stack}),
    do: match_paren({[head | output_queue], rest})

  def handle_operator(
        operator,
        {output_queue, operator_stack},
        operator_precedences
      ) do
    case Map.get(operator_precedences, Enum.at(operator_stack, 0)) do
      nil ->
        {output_queue, [operator | operator_stack]}

      precedence ->
        [head | rest] = operator_stack

        if precedence >= Map.get(operator_precedences, operator) do
          handle_operator(operator, {[head | output_queue], rest}, operator_precedences)
        else
          {output_queue, [operator | operator_stack]}
        end
    end
  end

  def to_op_func("+"), do: &Kernel.+/2
  def to_op_func("*"), do: &Kernel.*/2

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.replace(" ", "")
      |> String.graphemes()
    end)
  end
end
