defmodule Day3 do
  def test_input do
    """
    ..##.......
    #...#...#..
    .#....#..#.
    ..#.#...#.#
    .#...##..#.
    ..#.##.....
    .#.#.#....#
    .#........#
    #.##...#...
    #...##....#
    .#..#...#.#
    """
  end

  def solve_part_1(input) do
    [h | _t] = list = parse(input)
    line_length = String.length(h)

    list
    |> Enum.reduce({0, 0}, fn line, {acc, index} ->
      if String.at(line, rem(index * 3, line_length)) == "#" do
        {acc + 1, index + 1}
      else
        {acc, index + 1}
      end
    end)
    |> elem(0)
  end

  def solve_part_2(input) do
    [h | _t] = list = parse(input)
    line_length = String.length(h)

    slopes = [
      {1, 1},
      {3, 1},
      {5, 1},
      {7, 1},
      {1, 2}
    ]

    slopes
    |> Enum.reduce(1, fn {x, y}, acc ->
      {trees, _} =
        list
        |> Enum.reduce({0, 0}, fn line, {acc, index} ->
          if rem(index, y) == 0 and String.at(line, rem(div(index, y) * x, line_length)) == "#" do
            {acc + 1, index + 1}
          else
            {acc, index + 1}
          end
        end)

      acc * trees
    end)
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
  end
end
