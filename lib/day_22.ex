defmodule Day22 do
  def test_input do
    """
    Player 1:
    9
    2
    6
    3
    1

    Player 2:
    5
    8
    4
    7
    10
    """
  end

  def solve_part_1(input), do: do_solve(input, &combat/1)

  def solve_part_2(input) do
    do_solve(input, fn [player_1, player_2] ->
      player_1 |> recursive_combat(player_2) |> elem(1)
    end)
  end

  def do_solve(input, game) do
    input
    |> parse
    |> game.()
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {card, index} -> card * index end)
    |> Enum.sum()
  end

  def combat([player_1, player_2]), do: combat(player_1, player_2)

  def combat(player_1, player_2) do
    {card_1, player_1} = get_value(player_1)
    {card_2, player_2} = get_value(player_2)

    case {card_1, card_2} do
      {card, :empty} ->
        add_to_front(player_1, card)

      {:empty, card} ->
        add_to_front(player_2, card)

      {card_1, card_2} when card_1 > card_2 ->
        player_1
        |> add_to_back(card_1)
        |> add_to_back(card_2)
        |> combat(player_2)

      {card_1, card_2} when card_1 < card_2 ->
        player_2
        |> add_to_back(card_2)
        |> add_to_back(card_1)
        |> (&combat(player_1, &1)).()
    end
  end

  def recursive_combat(player_1, player_2, history \\ {MapSet.new(), MapSet.new()})

  def recursive_combat(player_1, _player_2, nil), do: {:player_1, player_1}

  def recursive_combat(player_1_full, player_2_full, history) do
    {card_1, player_1} = get_value(player_1_full)
    {card_2, player_2} = get_value(player_2_full)

    next_history = unique_state(player_1_full, player_2_full, history)

    if card_1 <= length(player_1) and card_2 <= length(player_2) do
      case recursive_combat(sub_deck(player_1, card_1), sub_deck(player_2, card_2)) do
        {:player_1, _deck} ->
          player_1 = add_cards(player_1, card_1, card_2)
          recursive_combat(player_1, player_2, next_history)

        {:player_2, _deck} ->
          player_2 = add_cards(player_2, card_2, card_1)
          recursive_combat(player_1, player_2, next_history)
      end
    else
      do_combat(card_1, card_2, player_1, player_2, next_history)
    end
  end

  def do_combat(card_1, :empty, player_1, _player_2, _history) do
    {:player_1, add_to_front(player_1, card_1)}
  end

  def do_combat(:empty, card_2, _player_1, player_2, _history) do
    {:player_2, add_to_front(player_2, card_2)}
  end

  def do_combat(card_1, card_2, player_1, player_2, history) when card_1 > card_2 do
    player_1 = add_cards(player_1, card_1, card_2)
    recursive_combat(player_1, player_2, history)
  end

  def do_combat(card_1, card_2, player_1, player_2, history) when card_1 < card_2 do
    player_2 = add_cards(player_2, card_2, card_1)
    recursive_combat(player_1, player_2, history)
  end

  def add_cards(q, e1, e2), do: q |> add_to_back(e1) |> add_to_back(e2)

  def sub_deck(list, n), do: Enum.take(list, n)

  def unique_state(player_1, player_2, {p1_state, p2_state}) do
    unless MapSet.member?(p1_state, player_1) or MapSet.member?(p2_state, player_2) do
      {MapSet.put(p1_state, player_1), MapSet.put(p2_state, player_2)}
    end
  end

  def add_to_back(list, item), do: Enum.concat(list, [item])
  def add_to_front(list, item), do: [item | list]

  def get_value(list) do
    case list do
      [value | rest] -> {value, rest}
      _ -> {:empty, []}
    end
  end

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn deck ->
      deck
      |> String.split("\n", trim: true)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
