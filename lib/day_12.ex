defmodule Day12 do
  def test_input do
    """
    F10
    N3
    F7
    R90
    F11
    """
  end

  def solve_part_1(input) do
    {_dir, x, y} =
      input
      |> parse()
      |> Enum.reduce({"E", 0, 0}, fn {_inst, _arg} = instruction, {_dir, _x, _y} = state ->
        next(instruction, state)
      end)

    abs(x) + abs(y)
  end

  def next({"N", arg}, {dir, x, y}), do: {dir, x + arg, y}
  def next({"S", arg}, {dir, x, y}), do: {dir, x - arg, y}
  def next({"E", arg}, {dir, x, y}), do: {dir, x, y + arg}
  def next({"W", arg}, {dir, x, y}), do: {dir, x, y - arg}
  def next({"F", arg}, {dir, _, _} = state), do: next({dir, arg}, state)

  def next({inst, arg}, {dir, x, y}) when inst in ["L", "R"] do
    turn = if(inst == "R", do: &turn_right/1, else: &turn_left/1)
    new_dir = do_turn(dir, turn, div(arg, 90))

    {new_dir, x, y}
  end

  def do_turn(dir, _turn_fn, 0), do: dir
  def do_turn(dir, turn_fn, n), do: dir |> turn_fn.() |> do_turn(turn_fn, n - 1)

  def turn_right("N"), do: "E"
  def turn_right("E"), do: "S"
  def turn_right("S"), do: "W"
  def turn_right("W"), do: "N"

  def turn_left("N"), do: "W"
  def turn_left("W"), do: "S"
  def turn_left("S"), do: "E"
  def turn_left("E"), do: "N"

  def solve_part_2(input) do
    {{x, y}, _waypoint} =
      input
      |> parse()
      |> Enum.reduce({{0, 0}, {1, 10}}, fn {_inst, _arg} = instruction,
                                           {_ship, _waypoint} = state ->
        next_2(instruction, state)
      end)

    abs(x) + abs(y)
  end

  def next_2({"N", arg}, {ship, {x, y}}), do: {ship, {x + arg, y}}
  def next_2({"S", arg}, {ship, {x, y}}), do: {ship, {x - arg, y}}
  def next_2({"E", arg}, {ship, {x, y}}), do: {ship, {x, y + arg}}
  def next_2({"W", arg}, {ship, {x, y}}), do: {ship, {x, y - arg}}

  def next_2({"F", arg}, {{sx, sy}, {wx, wy}}) do
    tx = (wx - sx) * arg
    ty = (wy - sy) * arg

    {{sx + tx, sy + ty}, {wx + tx, wy + ty}}
  end

  def next_2({inst, arg}, {{sx, sy} = ship, {wx, wy} = _waypoint}) when inst in ["L", "R"] do
    x_dif = wx - sx
    y_dif = wy - sy

    case {arg, inst} do
      {180, _} -> {ship, {sx - x_dif, sy - y_dif}}
      {90, "L"} -> {ship, {sx + y_dif, sy - x_dif}}
      {90, "R"} -> {ship, {sx - y_dif, sy + x_dif}}
      {270, "L"} -> {ship, {sx - y_dif, sy + x_dif}}
      {270, "R"} -> {ship, {sx + y_dif, sy - x_dif}}
    end
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn <<insturction::binary-size(1), argument::binary>> ->
      {insturction, String.to_integer(argument)}
    end)
  end
end
