defmodule Day1 do
  @number_map %{
    "1" => 1,
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9
  }

  def main do
    {:ok, input} = File.read("day01input")

    input
    |> String.split("\n")
    |> Enum.reject(fn line -> line == "" end)
    |> Enum.map(fn line ->
      {n, ""} = Integer.parse("#{first_number(line)}#{last_number(line)}")
      n
    end)
    |> Enum.sum()
  end

  def first_number(line) do
    line
    |> first_string_number(string_numbers())
    |> to_int()
  end

  def last_number(line) do
    line
    |> last_string_number()
    |> to_int()
  end

  def first_string_number(<<_, rest::binary>> = line, numbers) do
    Enum.find(numbers, fn number_str -> String.starts_with?(line, number_str) end) ||
      first_string_number(rest, numbers)
  end

  def last_string_number(line) do
    line
    |> String.reverse()
    |> first_string_number(reversed_string_numbers())
    |> String.reverse()
  end

  def to_int(str) do
    @number_map[str]
  end

  def string_numbers do
    Map.keys(@number_map)
  end

  def reversed_string_numbers do
    Enum.map(string_numbers(), &String.reverse/1)
  end
end

IO.puts(Day1.main())
