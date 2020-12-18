defmodule Day18 do
  def test_input_1 do
    """
    ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2
    """
  end

  def solve_part_1(input) do
    input
    |> parse()
    |> Enum.map(&evaluate/1)
    |> Enum.sum()
  end

  def evaluate(token) when is_list(token), do: Enum.reduce(token, nil, &do_eval/2)

  def do_eval(token, nil) when is_integer(token), do: token
  def do_eval(token, acc) when is_integer(token) and is_function(acc), do: acc.(token)
  def do_eval("+", acc), do: &Kernel.+(acc, &1)
  def do_eval("*", acc), do: &Kernel.*(acc, &1)
  def do_eval(token, acc) when is_list(token), do: do_eval(evaluate(token), acc)

  def test_input_2 do
    """
    1 + (2 * 3) + (4 * (5 + 6))
    2 * 3 + (4 * 5)
    5 + (8 * 3 + 9 + 3 * 4 * 3)
    5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))
    ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2
    """
  end

  def solve_part_2(input) do
    input
    |> parse()
    |> Enum.map(&evaluate_2/1)
    |> Enum.sum()
  end

  def evaluate_2(token) when is_list(token) do
    token
    |> evaluate_2("+")
    |> evaluate_2("*")
  end

  def evaluate_2(int) when is_integer(int), do: int

  def evaluate_2(int, _operator) when is_integer(int), do: int
  def evaluate_2([token], operator), do: evaluate_2(token, operator)
  def evaluate_2([left | [operator | [right | rest]]], operator) do
    op_func = to_op_func(operator)

    evaluated =
      left
      |> evaluate_2()
      |> op_func.(evaluate_2(right))

    if Enum.empty?(rest) do
      evaluated
    else
      evaluate_2([evaluated | rest], operator)
    end
  end

  def evaluate_2([left | [different_operator | rest]], operator) do
    [left | [different_operator | [evaluate_2(rest, operator)]]]
  end

  def to_op_func("+"), do: &Kernel.+/2
  def to_op_func("*"), do: &Kernel.*/2

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      body =
        String.replace(line, ["(", ")", "+", "*", " "], fn
          "(" -> "["
          ")" -> "]"
          "+" -> ~s/"+"/
          "*" -> ~s/"*"/
          " " -> ", "
        end)

      ("[" <> body <> "]")
      |> Code.eval_string()
      |> elem(0)
    end)
  end
end
