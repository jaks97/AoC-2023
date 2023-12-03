replacements = %{
  "zero" => "z0o",
  "one" => "o1e",
  "two" => "t2o",
  "three" => "t3e",
  "four" => "f4r",
  "five" => "f5e",
  "six" => "s6x",
  "seven" => "s7n",
  "eight" => "e8t",
  "nine" => "n9e",
}

replace_strings = fn str ->
  replacements
    |> Enum.reduce(str, fn {key, value}, acc ->
      String.replace(acc, key, value)
    end)
end

calibration_value = fn str ->
  str
    |> replace_strings.()
    |> String.to_charlist
    |> Enum.filter(&(&1 in ?0..?9))
    |> Enum.map(&(&1 - ?0))
    |> (&[Enum.at(&1, 0, ?0) * 10, Enum.at(&1, -1, ?0)]).()
    |> Enum.sum
end

File.read("input.txt")
  |> elem(1)
  |> String.split("\n")
  |> Enum.map(calibration_value)
  |> Enum.sum
  |> IO.puts

# 54885
