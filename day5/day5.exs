defmodule Day5 do

  def get_seeds do
    File.read!("input.txt")
      |> String.split("\n")
      |> Enum.at(0) # get first line
      |> String.slice(7..-1) # trim "seeds: " from start
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
  end

  def value_for_map {source_start, destination_start, length}, num do
    case num in source_start..(source_start + length - 1) do
      true -> destination_start + (num - source_start)
      false -> :not_in_range
    end
  end

  def mapping_function maps do
    fn num ->
      mapped_value = maps |> Enum.map(fn map -> map |> value_for_map(num) end) |> Enum.filter(fn value -> value != :not_in_range end)


      case mapped_value do
        [] -> num
        [value] -> value
      end
    end
  end

  def parse_line line do
    [destination_start, source_start, length] = line
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

    {source_start, destination_start, length}
  end


  def parse_map map do
    [title | map] = map |> String.split("\n")

    [from, _, to] = title
      |> String.slice(0..-6) # trim " map:" from end
      |> String.split("-")

    # map = %{ source => mapping_function }
    map = map
      |> Enum.map(&parse_line/1)
      |> mapping_function

    %{{from, to} => map}
  end

  def get_maps do
    File.read!("input.txt")
      |> String.split("\n\n")
      |> Enum.drop(1)
      |> Enum.map(&parse_map/1)
      |> Enum.reduce(%{}, fn map, acc -> Map.merge(map, acc) end)
  end

  def find_next_map maps, {_from, to} do
    maps |> Enum.filter(fn {{next_from, _next_to}, _map} -> next_from == to end) |> Enum.at(0)
  end

  def merge_maps map_a, map_b do
    {{from, _to_a}, map_fn_a} = map_a
    {{_from_b, to}, map_fn_b} = map_b

    merged_map_fn = fn num ->
      map_fn_b.(map_fn_a.(num))
    end

    {{from, to}, merged_map_fn}
  end

  def compact_maps maps do
    case maps |> Map.keys() do
      [_single_key] -> maps # there is only one map so we are already compacted
      _ -> maps
        |> Enum.reduce(maps, fn {key, _map_fn}, acc ->
          {map_fn, acc} = acc |> Map.pop(key)
          next_map = find_next_map(acc, key)

          cond do
            map_fn == nil -> acc # current map have been merged already
            next_map == nil -> acc # there is no next map so we are in the last one

            true ->
              {merged_key, merged_map_fn} = merge_maps({key, map_fn}, next_map)

              acc
                |> Map.pop(next_map |> elem(0)) |> elem(1)
                |> Map.put(merged_key, merged_map_fn)
          end

        end)
        |> compact_maps # do it again until we have only one map
    end

  end
end

map = Day5.get_maps
  |> Day5.compact_maps
  |> Map.values
  |> Enum.at(0)

Day5.get_seeds
  |> Enum.map(fn key -> map |> apply([key]) end)
  |> Enum.min
  |> IO.puts
