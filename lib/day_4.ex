defmodule Day4 do
  def test_input do
    """
    ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
    byr:1937 iyr:2017 cid:147 hgt:183cm

    iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
    hcl:#cfa07d byr:1929

    hcl:#ae17e1 iyr:2013
    eyr:2024
    ecl:brn pid:760753108 byr:1931
    hgt:179cm

    hcl:#cfa07d eyr:2025 pid:166559648
    iyr:2011 ecl:brn hgt:59in
    """
  end

  def invalid do
    """
    eyr:1972 cid:100
    hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

    iyr:2019
    hcl:#602927 eyr:1967 hgt:170cm
    ecl:grn pid:012533040 byr:1946

    hcl:dab227 iyr:2012
    ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

    hgt:59cm ecl:zzz
    eyr:2038 hcl:74454a iyr:2023
    pid:3556412378 byr:2007
    """
  end

  def valid do
    """
    pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
    hcl:#623a2f

    eyr:2029 ecl:blu cid:129 byr:1989
    iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

    hcl:#888785
    hgt:164cm byr:2001 iyr:2015 cid:88
    pid:545766238 ecl:hzl
    eyr:2022

    iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
    """
  end

  @parse_pattern ~r/(:| |\n)/

  def solve_part_1(input) do
    input
    |> parse()
    |> Enum.count(&check_passports/1)
  end

  defp check_passports(%{
         "byr" => _,
         "iyr" => _,
         "eyr" => _,
         "hgt" => _,
         "hcl" => _,
         "ecl" => _,
         "pid" => _
       }) do
    true
  end

  defp check_passports(_other), do: false

  def solve_part_2(input) do
    input
    |> parse()
    |> Stream.map(&check_passports_2/1)
    |> Enum.count()
  end

  defp check_passports_2(%{
         "byr" => byr,
         "iyr" => iyr,
         "eyr" => eyr,
         "hgt" => hgt,
         "hcl" => hcl,
         "ecl" => ecl,
         "pid" => pid
       }) do
    validate(:byr, byr) and
      validate(:iyr, iyr) and
      validate(:eyr, eyr) and
      validate(:hgt, hgt) and
      validate(:hcl, hcl) and
      validate(:ecl, ecl) and
      validate(:pid, pid)
  end

  defp check_passports_2(_other), do: false

  # byr (Birth Year) - four digits; at least 1920 and at most 2002.
  def validate(:byr, byr), do: validate_number(byr, fn n -> n in 1920..2002 end)

  # iyr (Issue Year) - four digits; at least 2010 and at most 2020.
  def validate(:iyr, iyr), do: validate_number(iyr, fn n -> n in 2010..2020 end)

  # eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
  def validate(:eyr, eyr), do: validate_number(eyr, fn n -> n in 2020..2030 end)

  # hgt (Height) - a number followed by either cm or in:
  # If cm, the number must be at least 150 and at most 193.
  # If in, the number must be at least 59 and at most 76.
  def validate(:hgt, <<height::binary-size(3), "cm">>),
    do: validate_number(height, fn n -> n in 150..193 end)

  def validate(:hgt, <<height::binary-size(2), "in">>),
    do: validate_number(height, fn n -> n in 59..76 end)

  # hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
  def validate(:hcl, <<"#", hcl::binary-size(6)>>), do: Regex.match?(~r/[0-9a-f]{6}/, hcl)

  # ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
  def validate(:ecl, ecl), do: Enum.member?(~w/amb blu brn gry grn hzl oth/, ecl)

  # pid (Passport ID) - a nine-digit number, including leading zeroes.
  def validate(:pid, <<pid::binary-size(9)>>), do: Regex.match?(~r/[0-9]{9}/, pid)

  def validate(_, _), do: false

  def validate_number(string, validator) do
    string
    |> String.to_integer()
    |> validator.()
  rescue
    _ -> false
  end

  def parse(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&String.split(&1, @parse_pattern))
    |> Enum.map(&create_map/1)
  end

  defp create_map(line) do
    line
    |> Enum.chunk_every(2)
    |> Enum.reduce(%{}, fn [k, v], acc -> Map.put(acc, k, v) end)
  end
end
