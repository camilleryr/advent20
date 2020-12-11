defmodule Day11 do
  def test_input do
    """
    L.LL.LL.LL
    LLLLLLL.LL
    L.L.L..L..
    LLLL.LL.LL
    L.LL.LL.LL
    L.LLLLL.LL
    ..L.L.....
    LLLLLLLLLL
    L.LLLLLL.L
    L.LLLLL.LL
    """
  end

  @empty "L"
  @filled "#"
  @floor "."

  def solve_part_1(input) do
    input
    |> parse()
    |> do_solve(&eval_rules_pt_1/3)
  end

  def solve_part_2(input) do
    input
    |> parse()
    |> do_solve(&eval_rules_pt_2/3)
  end

  def do_solve(previous, rule_evaluator) do
    previous
    |> to_next_state(rule_evaluator)
    |> case do
      ^previous = next ->
        next
        |> Enum.filter(fn
          {_index, @filled} -> true
          _ -> false
        end)
        |> Enum.count()

      next ->
        do_solve(next, rule_evaluator)
    end
  end

  def to_next_state(previous, rule_evaluator) do
    Map.new(previous, fn {k, v} -> {k, rule_evaluator.(v, k, previous)} end)
  end

  def eval_rules_pt_1(value, key, previous) do
    eval_rules(value, key, previous, &adjacent/1, filled_guard_value: 4)
  end

  def eval_rules_pt_2(value, key, previous) do
    directions = adjacent({0, 0})

    eval_rules(
      value,
      key,
      previous,
      fn x -> Enum.map(directions, &find_nearest_seat(&1, x, previous)) end,
      filled_guard_value: 5
    )
  end

  def find_nearest_seat({dx, dy} = direction, {x, y}, state) do
    key = {x + dx, y + dy}

    if not(Map.get(state, key) == @floor) do
      key
    else
      find_nearest_seat(direction, key, state)
    end
  end

  def adjacent({x, y} = key) do
    for xs <- (x - 1)..(x + 1), ys <- (y - 1)..(y + 1), {xs, ys} != key, do: {xs, ys}
  end

  def eval_rules(@floor, _key, _state, _find_seats, _opts), do: @floor

  def eval_rules(@empty, key, state, find_seats, _opts) do
    key
    |> find_seats.()
    |> Enum.all?(fn key -> Map.get(state, key) != @filled end)
    |> if(do: @filled, else: @empty)
  end

  def eval_rules(@filled, key, state, find_seats, opts) do
    guard_value = Keyword.fetch!(opts, :filled_guard_value)

    key
    |> find_seats.()
    |> Enum.filter(fn val -> Map.get(state, val) == @filled end)
    |> case do
      list when length(list) >= guard_value -> @empty
      _ -> @filled
    end
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {outter_el, outter_i}, acc ->
      outter_el
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {inner_el, inner_i}, inner_acc ->
        Map.put(inner_acc, {outter_i, inner_i}, inner_el)
      end)
    end)
  end
end
