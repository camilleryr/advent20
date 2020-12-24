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
    do_solve(input, fn [player_2, player_1] ->
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

  def combat([player_2, player_1]), do: combat(player_1, player_2)

  def combat(player_1, player_2) do
    case {player_1, player_2} do
      {player_1, []} ->
        player_1

      {[], player_2} ->
        player_2

      {[card_1 | player_1], [card_2 | player_2]} when card_1 > card_2 ->
        player_1
        |> add_cards(card_1, card_2)
        |> combat(player_2)

      {[card_1 | player_1], [card_2 | player_2]} when card_1 < card_2 ->
        player_2
        |> add_cards(card_2, card_1)
        |> (&combat(player_1, &1)).()
    end
  end

  def recursive_combat(player_1, player_2, history \\ MapSet.new())

  def recursive_combat(player_1, _player_2, nil), do: {:player_1, player_1}

  def recursive_combat(player_1, player_2, history) do
    do_combat(player_1, player_2, unique_state(player_1, player_2, history))
  end

  def do_combat(player_1, [], _history) do
    {:player_1, player_1}
  end

  def do_combat([], player_2, _history) do
    {:player_2, player_2}
  end

  def do_combat([card_1 | player_1], [card_2 | player_2], history)
      when card_1 <= length(player_1) and card_2 <= length(player_2) do
    case recursive_combat(sub_deck(player_1, card_1), sub_deck(player_2, card_2)) do
      {:player_1, _deck} ->
        [add_cards(player_1, card_1, card_2), player_2, history]

      {:player_2, _deck} ->
        [player_1, add_cards(player_2, card_2, card_1), history]
    end
    |> flip_apply(&recursive_combat/3)
  end

  def do_combat([card_1 | player_1], [card_2 | player_2], history) when card_1 > card_2 do
    player_1 = add_cards(player_1, card_1, card_2)
    recursive_combat(player_1, player_2, history)
  end

  def do_combat([card_1 | player_1], [card_2 | player_2], history) when card_1 < card_2 do
    player_2 = add_cards(player_2, card_2, card_1)
    recursive_combat(player_1, player_2, history)
  end

  def add_cards(q, e1, e2), do: q ++ [e1, e2]

  def sub_deck(list, n), do: Enum.take(list, n)

  def unique_state(player_1, player_2, state) do
    unless MapSet.member?(state, player_1) or MapSet.member?(state, player_2) do
      MapSet.put(state, player_1) |> MapSet.put(player_2)
    end
  end

  def flip_apply(args, fun), do: apply(fun, args)

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce([], fn
      <<"Player", _rest::binary>>, acc -> [[] | acc]
      num, [h | t] -> [[String.to_integer(num) | h] | t]
    end)
    |> Enum.map(&Enum.reverse/1)
  end
end
