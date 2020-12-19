defmodule Day19 do
  def test_input do
    """
    0: 4 1 5
    1: 2 3 | 3 2
    2: 4 4 | 5 5
    3: 4 5 | 5 4
    4: "a"
    5: "b"

    ababbb
    bababa
    abbbab
    aaabbb
    aaaabbb
    """
  end

  def test_input_2 do
    """
    42: 9 14 | 10 1
    9: 14 27 | 1 26
    10: 23 14 | 28 1
    1: "a"
    11: 42 31
    5: 1 14 | 15 1
    19: 14 1 | 14 14
    12: 24 14 | 19 1
    16: 15 1 | 14 14
    31: 14 17 | 1 13
    6: 14 14 | 1 14
    2: 1 24 | 14 4
    0: 8 11
    13: 14 3 | 1 12
    15: 1 | 14
    17: 14 2 | 1 7
    23: 25 1 | 22 14
    28: 16 1
    4: 1 1
    20: 14 14 | 1 15
    3: 5 14 | 16 1
    27: 1 6 | 14 18
    14: "b"
    21: 14 1 | 1 14
    25: 1 1 | 1 14
    22: 14 14
    8: 42
    26: 14 22 | 1 20
    18: 15 15
    7: 14 5 | 1 21
    24: 14 1

    abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
    bbabbbbaabaabba
    babbbbaabbbbbabbbbbbaabaaabaaa
    aaabbbbbbaaaabaababaabababbabaaabbababababaaa
    bbbbbbbaaaabbbbaaabbabaaa
    bbbababbbbaaaaaaaabbababaaababaabab
    ababaaaaaabaaab
    ababaaaaabbbaba
    baabbaaaabbaaaababbaababb
    abbbbabbbbaaaababbbbbbaaaababb
    aaaaabbaabaaaaababaa
    aaaabbaaaabbaaa
    aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
    babaaabbbaaabaababbaabababaaab
    aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
    """
  end

  def solve_part_1(input) do
    {rules, messages} = parse(input)

    do_solve(rules, messages)
  end

  def solve_part_2(input) do
    {rules, messages} = input |> parse()

    rules =
      rules
      |> Map.put("8", {:loop, ["42"]})
      |> Map.put("11", {:loop, ["42", "31"]})

    do_solve(rules, messages)
  end

  def do_solve(rules, messages) do
    rule =
      rules
      |> Map.get("0")
      |> to_pattern(rules)
      |> Regex.compile!()

    messages
    |> Enum.filter(&Regex.match?(rule, &1))
    |> Enum.count()
  end

  def to_pattern(rule, rules), do: "^#{do_to_pattern(rule, rules)}$"

  def do_to_pattern({:and, list}, rules) do
    list
    |> Enum.map(&do_to_pattern(&1, rules))
    |> Enum.join()
  end

  def do_to_pattern({:loop, to_loop}, rules) do
    if length(to_loop) == 1 do
      [a] = to_loop
      "(#{do_to_pattern(a, rules)}+)"
    else
      [a, b] = to_loop |> Enum.map(&do_to_pattern(&1, rules))

      "(?P<self>#{a}(?&self)?#{b})"
    end
  end

  def do_to_pattern({:or, [left, right]}, rules) do
    left = do_to_pattern(left, rules)
    right = do_to_pattern(right, rules)

    "(#{left}|#{right})"
  end

  def do_to_pattern({:letter, letter}, _rules), do: letter

  def do_to_pattern(pointer, rules), do: do_to_pattern(Map.get(rules, pointer), rules)

  def parse(input) do
    [rules, messages] =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    rules =
      rules
      |> Enum.map(fn line ->
        [key, rules] = String.split(line, ": ")

        rules =
          case rules do
            <<"\"", letter::binary-size(1), "\"">> ->
              {:letter, letter}

            _ ->
              if String.contains?(rules, "|") do
                [l, r] =
                  rules
                  |> String.split(" | ")
                  |> Enum.map(&String.split(&1, " "))

                {:or, [{:and, l}, {:and, r}]}
              else
                r =
                  rules
                  |> String.split(" ")

                {:and, r}
              end
          end

        {key, rules}
      end)
      |> Map.new()

    {rules, messages}
  end
end
