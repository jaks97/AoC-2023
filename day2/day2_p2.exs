parse_color_count = fn str ->
  [count, color] = str |> String.split(" ")

  %{color => String.to_integer count} # TODO: Can this be a single key value rather than a map?
end

parse_revealed_cubes = fn str ->
  str
    |> String.split(", ")
    |> Enum.map(parse_color_count)
    |> Enum.reduce(%{}, fn map, acc -> Map.merge(map, acc) end)
end

parse_game_line = fn str ->
  [id, data] = str |> String.split(": ")

  id = id
    |> String.slice(5..-1) # Trim "Game " from the beginning
    |> String.to_integer

  data = data
    |> String.split("; ")
    |> Enum.map(parse_revealed_cubes)

  {id, data}
end

min_needed_for_game = fn {_id, sets} ->
  amounts = %{"red" => 0, "green" => 0, "blue" => 0}

  sets
    |> Enum.reduce(amounts, fn set, acc ->
      Map.merge(set, acc, fn _key, val1, val2 -> max(val1, val2) end)
    end)
end

power_of_set = fn set ->
  set
    |> Map.values
    |> Enum.reduce(1, fn val, acc -> val * acc end)
end

File.read("input.txt")
  |> elem(1)
  |> String.split("\n")
  |> Enum.map(parse_game_line)
  |> Enum.map(min_needed_for_game)
  |> Enum.map(power_of_set)
  |> Enum.sum
  |> IO.puts

# 63307
