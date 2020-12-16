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
    {_rules, rule, _, nearby_tickets} = parse(input)

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
    {rules, rule, my_ticket, nearby_tickets} = parse(input)

    nearby_tickets
    |> Enum.filter(&tickets_with_invalid_numbers(&1, rule))
    |> Enum.concat([my_ticket])
    |> Enum.reduce(%{}, &to_columnar_value_map/2)
    |> Map.new(&match_column_to_valid_rules(&1, rules))
    |> find_distinct_rule_per_column()
    |> Enum.filter(&non_depature_rules/1)
    |> Enum.map(&get_rule_values_from_ticket(my_ticket, &1))
    |> Enum.reduce(1, &Kernel.*/2)
  end

  def non_depature_rules({_position, name}), do: String.starts_with?(name, "departure")

  def match_column_to_valid_rules({column, value_set}, rules),
    do: {column, find_matching_rules(value_set, rules)}

  def get_rule_values_from_ticket(my_ticket, {column_index, _name}) do
    Enum.find_value(my_ticket, fn
      {value, ^column_index} -> value
      _ -> false
    end)
  end

  def find_matching_rules(value_set, rules) do
    rules
    |> Enum.filter(fn {_name, valid_set} -> MapSet.subset?(value_set, valid_set) end)
    |> Enum.map(fn {name, _valid_set} -> name end)
  end

  def to_columnar_value_map(ticket, map),
    do: Enum.reduce(ticket, map, &add_ticket_column_value_to_map/2)

  def add_ticket_column_value_to_map({number, column}, map),
    do: Map.update(map, column, MapSet.new([number]), &MapSet.put(&1, number))

  def tickets_with_invalid_numbers(ticket, rule), do: Enum.all?(ticket, &number_in_rule(&1, rule))

  def number_in_rule({number, _}, rule), do: MapSet.member?(rule, number)

  def find_distinct_rule_per_column(start, finish \\ %{})
  def find_distinct_rule_per_column(start, finish) when start == %{}, do: finish

  def find_distinct_rule_per_column(start, finish) do
    {column, [rule]} = Enum.find(start, fn {_, rules} -> length(rules) == 1 end)

    new_finish = Map.put(finish, column, rule)

    start
    |> Map.delete(column)
    |> Map.new(fn {column, rs} -> {column, Enum.reject(rs, &(&1 == rule))} end)
    |> find_distinct_rule_per_column(new_finish)
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

    rule =
      rules
      |> Enum.map(&elem(&1, 1))
      |> Enum.reduce(&MapSet.union/2)

    my_ticket = gen_ticket_numbers(my_ticket)
    nearby_tickets = Enum.map(nearby_tickets, &gen_ticket_numbers/1)

    {rules, rule, my_ticket, nearby_tickets}
  end

  def gen_ticket_numbers(string) do
    string
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
  end
end
