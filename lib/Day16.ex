defmodule Day16 do
  def test_input do
    """
    class: 1-3 or 5-7
    row: 6-11 or 33-44
    seat: 13-40 or 45-50

    your ticket:
    7,1,14

    nearby tickets:
    7,3,47
    40,4,50
    55,2,20
    38,6,12
    """
  end

  def solve_part_1(input) do
    {rules, _, nearby_tickets} = input |> parse()

    rule =
      rules
      |> Enum.map(&elem(&1, 1))
      |> Enum.reduce(&MapSet.union/2)

    nearby_tickets
    |> Enum.flat_map(fn ticket ->
      Enum.map(ticket, &elem(&1, 0))
    end)
    |> Enum.frequencies()
    |> Enum.reduce(0, fn {number, frequency}, total ->
      if MapSet.member?(rule, number) do
        total
      else
        number * frequency + total
      end
    end)
  end

  def solve_part_2(input) do
    {rules, my_ticket, nearby_tickets} = input |> parse()

    rule =
      rules
      |> Enum.map(&elem(&1, 1))
      |> Enum.reduce(&MapSet.union/2)

    nearby_tickets
    |> Enum.filter(fn ticket ->
      Enum.all?(ticket, fn {number, _index} -> MapSet.member?(rule, number) end)
    end)
    |> Enum.concat([my_ticket])
    |> Enum.reduce(%{}, fn ticket, acc ->
      Enum.reduce(ticket, acc, fn {number, position}, acc_i ->
        Map.update(acc_i, position, MapSet.new([number]), &MapSet.put(&1, number))
      end)
    end)
    |> Map.new(fn {position, values} ->
      possible_rulse =
        rules
        |> Enum.reduce([], fn {name, set}, acc ->
          if MapSet.subset?(values, set) do
            [name | acc]
          else
            acc
          end
        end)

      {position, possible_rulse}
    end)
    |> match_rule_to_position()
    |> Enum.filter(fn {_pos, name} -> String.starts_with?(name, "departure") end)
    |> Enum.reduce(1, fn {pos, _name}, acc ->
      my_ticket
      |> Enum.find_value(fn {number, position} ->
        if position == pos do
          number
        end
      end)
      |> Kernel.*(acc)
    end)
  end

  def match_rule_to_position(start, finish \\ %{})
  def match_rule_to_position(start, finish) when start == %{}, do: finish

  def match_rule_to_position(start, finish) do
    {pos, [rule]} = Enum.find(start, fn {_, rules} -> length(rules) == 1 end)

    new_finish = Map.put(finish, pos, rule)

    start
    |> Map.delete(pos)
    |> Map.new(fn {p, rs} -> {p, Enum.reject(rs, &(&1 == rule))} end)
    |> match_rule_to_position(new_finish)
  end

  def parse(input) do
    [rules, [_, my_ticket], [_ | nearby_tickets]] =
      input |> String.split("\n\n", trim: true) |> Enum.map(&String.split(&1, "\n", trim: true))

    rules =
      rules
      |> Enum.map(&String.split(&1, ~r/(: |-| or )/))
      |> Enum.map(fn [name | numbers] ->
        [a, b, c, d] = Enum.map(numbers, &String.to_integer/1)
        valid_numbers = a..b |> Enum.concat(c..d) |> MapSet.new()
        {name, valid_numbers}
      end)

    my_ticket = gen_ticket_numbers(my_ticket)
    nearby_tickets = Enum.map(nearby_tickets, &gen_ticket_numbers/1)

    {rules, my_ticket, nearby_tickets}
  end

  def gen_ticket_numbers(string) do
    string
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
  end
end
