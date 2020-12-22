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
    |> :queue.to_list()
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {card, index} -> card * index end)
    |> Enum.sum()
  end

  def combat([player_1, player_2]), do: combat(player_1, player_2)

  def combat(player_1, player_2) do
    {card_1, player_1} = :queue.out(player_1)
    {card_2, player_2} = :queue.out(player_2)

    case {card_1, card_2} do
      {{:value, card}, :empty} ->
        add_to_front(player_1, card)

      {:empty, {:value, card}} ->
        add_to_front(player_2, card)

      {{:value, card_1}, {:value, card_2}} when card_1 > card_2 ->
        player_1
        |> add_to_back(card_1)
        |> add_to_back(card_2)
        |> combat(player_2)

      {{:value, card_1}, {:value, card_2}} when card_1 < card_2 ->
        player_2
        |> add_to_back(card_2)
        |> add_to_back(card_1)
        |> (&combat(player_1, &1)).()
    end
  end

  def recursive_combat(player_1, player_2, history \\ %{}, game_number \\ 1) do
    history = unique_state(player_1, player_2, game_number, history)

    if is_nil(history) do
      {:player_1, player_1}
    else
      {card_1, player_1} = :queue.out(player_1)
      {card_2, player_2} = :queue.out(player_2)

      player_1_remaining = :queue.len(player_1)
      player_2_remaining = :queue.len(player_2)

      case {card_1, card_2} do
        {{:value, card}, :empty} ->
          {:player_1, add_to_front(player_1, card)}

        {:empty, {:value, card}} ->
          {:player_2, add_to_front(player_2, card)}

        {{:value, card_1}, {:value, card_2}}
        when card_1 <= player_1_remaining and card_2 <= player_2_remaining ->
          {sub_deck_p1, _} = :queue.split(card_1, player_1)
          {sub_deck_p2, _} = :queue.split(card_2, player_2)

          case recursive_combat(sub_deck_p1, sub_deck_p2, history, game_number + 1) do
            {:player_1, _deck} ->
              player_1
              |> add_to_back(card_1)
              |> add_to_back(card_2)
              |> recursive_combat(player_2, history, game_number)

            {:player_2, _deck} ->
              player_2
              |> add_to_back(card_2)
              |> add_to_back(card_1)
              |> (&recursive_combat(player_1, &1, history, game_number)).()
          end

        {{:value, card_1}, {:value, card_2}} when card_1 > card_2 ->
          player_1
          |> add_to_back(card_1)
          |> add_to_back(card_2)
          |> recursive_combat(player_2, history, game_number)

        {{:value, card_1}, {:value, card_2}} when card_1 < card_2 ->
          player_2
          |> add_to_back(card_2)
          |> add_to_back(card_1)
          |> (&recursive_combat(player_1, &1, history, game_number)).()
      end
    end
  end

  def unique_state(player_1, player_2, game_number, history) do
    {p1_state, p2_state} = Map.get(history, game_number, {MapSet.new(), MapSet.new()})

    unless MapSet.member?(p1_state, player_1) or MapSet.member?(p2_state, player_2) do
      Map.put(
        history,
        game_number,
        {MapSet.put(p1_state, player_1), MapSet.put(p2_state, player_2)}
      )
    end
  end

  def add_to_back(queue, item), do: :queue.in(item, queue)
  def add_to_front(queue, item), do: :queue.in_r(item, queue)

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn deck ->
      deck
      |> String.split("\n", trim: true)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
      |> :queue.from_list()
    end)
  end
end
