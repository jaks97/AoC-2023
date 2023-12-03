defmodule Day3 do

  def get_numbers line, pos \\ 0 do
    len = line |> length

    cond do
      pos > len -> []

      Enum.at(line, pos) not in ?0..?9 -> get_numbers(line, pos + 1)

      true ->
        number_list = [Enum.at(line, pos)]
        number_list = Enum.reduce_while(line, number_list, fn _char, num ->
          num_len = num |> length

          cond do
            num_len + pos > len -> {:halt, num}

            Enum.at(line, pos + num_len) in ?0..?9 -> {:cont, num ++ [Enum.at(line, pos + num_len)]}

            true -> {:halt, num}
          end
        end)

        num_len = number_list |> length
        number = number_list |> List.to_integer

        [{pos, num_len, number} | get_numbers(line, pos + num_len)]
    end

  end

  def get_adjacent_characters matrix, {x, y} do
    max_y = matrix |> length
    max_x = matrix |> Enum.at(0) |> length

    adjacent_positions = [
      {x-1, y-1}, {x, y-1}, {x+1, y-1},
      {x-1, y},             {x+1, y},
      {x-1, y+1}, {x, y+1}, {x+1, y+1}
    ]
      |> Enum.filter(fn {x, y} -> x >= 0 and y >= 0 and x < max_x and y < max_y end)

    adjacent_positions
      |> Enum.map(fn {x, y} -> {matrix |> Enum.at(y) |> Enum.at(x), {x,y}} end)
  end

  def get_adjacent_characters matrix, {x, y}, len do
    x..(x + len - 1)
      |> Enum.map(fn x -> {x, y} end)
      |> Enum.flat_map(fn {x, y} -> get_adjacent_characters(matrix, {x, y}) end)
  end

  def get_adjacent_gears matrix, pos, len do
    gear = ?*

    get_adjacent_characters(matrix, pos, len)
      |> Enum.filter(fn {char, _pos} -> char == gear end)
      |> Enum.map(fn {_char, pos} -> pos end)
      |> Enum.uniq
  end

end

matrix = File.read("input.txt")
  |> elem(1)
  |> String.split("\n")
  |> Enum.map(&String.to_charlist/1)

numbers = matrix
  |> Enum.map(&Day3.get_numbers/1)


numbers_with_gears = 0..(length(numbers) - 1)
  |> Enum.zip(numbers) # add line number to each entry

  # map each number to its {x, y} position
  |> Enum.map(fn {line_number, numbers} ->
    numbers
      |> Enum.map(fn {pos, len, number} -> {{pos, line_number}, len, number} end)
  end)

  # flatten the list to be just a list of numbes {pos, len, number}
  |> Enum.flat_map(&(&1))

  # map to adjacent gears
  |> Enum.map(fn {pos, len, number} ->
    {pos, len, number, Day3.get_adjacent_gears(matrix, pos, len)}
  end)

  # filter out those that have no adjacent gears
  |> Enum.filter(fn {_pos, _len, _number, gears} -> length(gears) > 0 end)

gears = numbers_with_gears
  |> Enum.flat_map(fn {_pos, _len, _number, gears} -> gears end)
  |> Enum.uniq

# map all gears to all the numbers that are adjacent to them
gears
  |> Enum.map(fn gear_pos ->
    numbers_for_gear = numbers_with_gears
      |> Enum.filter(fn {_pos, _len, _number, gears} -> gear_pos in gears end)
      |> Enum.map(fn {_pos, _len, number, _gears} -> number end)

    {gear_pos, numbers_for_gear}
  end)

  # we only want those gears with exactly two numbers
  |> Enum.filter(fn {_gear_pos, numbers_for_gear} -> length(numbers_for_gear) == 2 end)

  # calculate the gear ratio
  |> Enum.map(fn {_gear_pos, numbers_for_gear} ->
    numbers_for_gear |> Enum.reduce(&(&1 * &2))
  end)
  # sum the gear ratios
  |> Enum.sum

  |> IO.puts
