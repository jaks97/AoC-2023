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

is_set_possible = fn set ->
  bag_contents = %{"red" => 12, "green" => 13, "blue" => 14}

  set
    |> Enum.all?(fn {color, count} ->
      count <= bag_contents[color]
    end)
end

is_game_possible = fn {_id, sets} ->
  sets |> Enum.all?(is_set_possible)
end

File.read("input.txt")
  |> elem(1)
  |> String.split("\n")
  |> Enum.map(parse_game_line)
  |> Enum.filter(is_game_possible)
  |> Enum.map(fn {id, _sets} -> id end)
  |> Enum.sum
  |> IO.puts

# 2416
