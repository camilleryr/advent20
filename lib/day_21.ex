defmodule Day21 do
  def test_input do
    """
    mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
    trh fvjkl sbzzf mxmxvkd (contains dairy)
    sqjhc fvjkl (contains soy)
    sqjhc mxmxvkd sbzzf (contains fish)
    """
  end

  def solve_part_1(input) do
    food_list = input |> parse()
    {translated_words, _dictionary} = translate(food_list)

    food_list
    |> Enum.flat_map(fn {ingredients, _allergens} -> ingredients end)
    |> Enum.reject(fn ingredient -> MapSet.member?(translated_words, ingredient) end)
    |> Enum.count()
  end

  def solve_part_2(input) do
    food_list = input |> parse()
    {_translated_words, dictionary} = translate(food_list)

    dictionary
    |> Enum.sort_by(fn {_word, translation} -> translation end)
    |> Enum.map(fn {word, _translation} -> word end)
    |> Enum.join(",")
  end

  def translate(food_list) do
    food_list
    |> Enum.reduce(%{}, fn {ingredients, allergens}, allergen_sets ->
      allergens
      |> Enum.reduce(allergen_sets, fn allergen, sets ->
        ingredient_set = MapSet.new(ingredients)

        Map.update(sets, allergen, ingredient_set, fn set ->
          MapSet.intersection(set, ingredient_set)
        end)
      end)
    end)
    |> translate_alergens()
  end

  def translate_alergens(translated_set \\ MapSet.new(), translated \\ [], to_translate)

  def translate_alergens(translated_set, translated, []) do
    {translated_set,
     Map.new(translated, fn {translation, set} ->
       {set |> MapSet.to_list() |> List.first(), translation}
     end)}
  end

  def translate_alergens(translated_set, translated, to_translate) do
    {newly_translated, still_to_tranlate} =
      to_translate
      |> Enum.map(fn {word, possibilities} ->
        {word, MapSet.difference(possibilities, translated_set)}
      end)
      |> Enum.split_with(fn {_allergen, possibilities} -> MapSet.size(possibilities) == 1 end)

    newly_translated
    |> Enum.reduce(translated_set, fn {_allergen, translated_alergen}, translated_alergens ->
      MapSet.union(translated_alergens, translated_alergen)
    end)
    |> translate_alergens(Enum.concat(translated, newly_translated), still_to_tranlate)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [words, alergens] = String.split(line, ["(contains ", ")"], trim: true)
      {~w/#{words}/, String.split(alergens, ", ")}
    end)
  end
end
