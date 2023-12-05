parse_numbers = fn line ->
  line
    |> String.split(" ")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&String.to_integer/1)
end

parse_game_line = fn line ->
  [card, data] = line |> String.split(": ")

  id = card
    |> String.split(" ")
    |> List.last
    |> String.to_integer

  [winning_numbers, actual_numbers] = data
    |> String.split("|")
    |> Enum.map(parse_numbers)

  {id, winning_numbers, actual_numbers}
end

win_count_to_points = fn win_count ->
  case win_count do
    0 -> 0
    _ -> 2 ** (win_count - 1)
  end
end

get_card_points = fn {_id, winning_numbers, actual_numbers} ->
  actual_numbers
    |> Enum.filter(fn num -> num in winning_numbers end)
    |> length
    |> win_count_to_points.()
end


File.read("input.txt")
  |> elem(1)
  |> String.split("\n")
  |> Enum.map(parse_game_line)
  |> Enum.map(get_card_points)
  |> Enum.sum
  |> IO.puts
