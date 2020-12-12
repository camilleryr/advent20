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

  def next({"F", arg}, {dir, _, _} = state), do: next({dir, arg}, state)

  def next({inst, _arg} = instruction, {dir, x, y}) when inst in ["N", "S", "E", "W"] do
    {new_x, new_y} = dir(instruction, {x, y})

    {dir, new_x, new_y}
  end

  def next({inst, arg}, {dir, x, y}) when inst in ["L", "R"] do
    {do_turn(dir, inst, div(arg, 90)), x, y}
  end

  def do_turn(dir, inst, 1), do: turn(inst, dir)
  def do_turn(dir, inst, n), do: inst |> turn(dir) |> do_turn(inst, n - 1)

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

  def next_2({inst, _arg} = instruction, {ship, waypoint}) when inst in ["N", "S", "E", "W"] do
    {ship, dir(instruction, waypoint)}
  end

  def next_2({"F", arg}, {{sx, sy}, {wx, wy}}) do
    tx = (wx - sx) * arg
    ty = (wy - sy) * arg

    {{sx + tx, sy + ty}, {wx + tx, wy + ty}}
  end

  def next_2({inst, arg}, {{ship_x, ship_y} = ship, {waypoint_x, waypoint_y} = _waypoint})
      when inst in ["L", "R"] do
    x_dif = waypoint_x - ship_x
    y_dif = waypoint_y - ship_y

    case {arg, inst} do
      {180, _} -> {ship, {ship_x - x_dif, ship_y - y_dif}}
      x when x in [{90, "L"}, {270, "R"}] -> {ship, {ship_x + y_dif, ship_y - x_dif}}
      x when x in [{90, "R"}, {270, "L"}] -> {ship, {ship_x - y_dif, ship_y + x_dif}}
    end
  end

  def turn("R", "N"), do: "E"
  def turn("R", "E"), do: "S"
  def turn("R", "S"), do: "W"
  def turn("R", "W"), do: "N"
  def turn("L", "N"), do: "W"
  def turn("L", "W"), do: "S"
  def turn("L", "S"), do: "E"
  def turn("L", "E"), do: "N"

  def dir({"N", arg}, {x, y}), do: {x + arg, y}
  def dir({"S", arg}, {x, y}), do: {x - arg, y}
  def dir({"E", arg}, {x, y}), do: {x, y + arg}
  def dir({"W", arg}, {x, y}), do: {x, y - arg}

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn <<insturction::binary-size(1), argument::binary>> ->
      {insturction, String.to_integer(argument)}
    end)
  end
end
