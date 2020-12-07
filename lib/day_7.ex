defmodule Day7 do
  def test_input do
    """
    light red bags contain 1 bright white bag, 2 muted yellow bags.
    dark orange bags contain 3 bright white bags, 4 muted yellow bags.
    bright white bags contain 1 shiny gold bag.
    muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
    shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
    dark olive bags contain 3 faded blue bags, 4 dotted black bags.
    vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
    faded blue bags contain no other bags.
    dotted black bags contain no other bags.
    """
  end

  def test_input_2 do
    """
    shiny gold bags contain 2 dark red bags.
    dark red bags contain 2 dark orange bags.
    dark orange bags contain 2 dark yellow bags.
    dark yellow bags contain 2 dark green bags.
    dark green bags contain 2 dark blue bags.
    dark blue bags contain 2 dark violet bags.
    dark violet bags contain no other bags.
    """
  end

  @my_bag_color "shiny gold"

  def solve_part_1(input) do
    input
    |> parse()
    |> do_solve_part_1([@my_bag_color], [])
    |> Enum.uniq()
    |> length()
  end

  def do_solve_part_1(rules, colors, results) do
    rules
    |> Enum.filter(fn {_key, %{"rules" => rules}} ->
      Enum.any?(rules, fn rule -> Enum.member?(colors, rule["color"]) end)
    end)
    |> Enum.map(fn {key, _} -> key end)
    |> case do
      [] -> results
      new_colors -> do_solve_part_1(rules, new_colors, new_colors ++ results)
    end
  end

  def solve_part_2(input) do
    input
    |> parse()
    |> do_solve_part_2(@my_bag_color)
    |> Enum.reduce(0, &Kernel.+(&1["number"], &2))
  end

  def do_solve_part_2(rules, color) do
    rules
    |> Map.get(color)
    |> Map.get("rules")
    |> case do
      [] ->
        []

      bag_rules ->
        bag_rules
        |> Enum.flat_map(fn bag_rule ->
          [
            bag_rule
            | Stream.cycle([do_solve_part_2(rules, bag_rule["color"])])
              |> Stream.take(bag_rule["number"])
              |> Enum.flat_map(& &1)
          ]
        end)
    end
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      ~r/^(?<rule_for>.+) bags contain (?<rules>.+)\./U
      |> Regex.named_captures(line)
      |> update_rules()
    end)
    |> Map.new()
  end

  def update_rules(%{"rule_for" => rule_for, "rules" => rules}) do
    case rules do
      "no other bags" ->
        {rule_for, %{"rules" => []}}

      rules ->
        {rule_for,
         %{
           "rules" =>
             rules
             |> String.split(", ")
             |> Enum.map(&Regex.named_captures(~r/(?<number>\d+) (?<color>.+) bags?/, &1))
             |> Enum.map(fn map -> Map.update!(map, "number", &String.to_integer/1) end)
         }}
    end
  end
end
