defmodule Day5 do
  #2.04 s
  def get_seeds do
    File.read!("input.txt")
      |> String.split("\n")
      |> Enum.at(0) # get first line
      |> String.slice(7..-1) # trim "seeds: " from start
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2) # get them in pairs
      |> Enum.map(fn [start, length] -> start..(start + length - 1) end)
  end

  def parse_line line do
    [destination_start, source_start, length] = line
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

    range = destination_start..(destination_start + length - 1)
    offset = source_start - destination_start

    {range, offset}
  end

  def mega_range_builder ranges do
    mega_range_start = ranges
      |> Enum.map(fn range -> Enum.at(range, 0) end)
      |> Enum.min()

    mega_range_end = ranges
      |> Enum.map(fn range -> Enum.at(range, -1) end)
      |> Enum.max()

    mega_range_start..mega_range_end
  end

  def mapping_function {range, tree_l, tree_r}, num do
    case num in range do
      false -> :not_in_range
      true -> [tree_l, tree_r]
        |> Enum.map(fn tree -> mapping_function(tree, num) end)
        |> Enum.find(num, fn value -> value != :not_in_range end)
    end
  end

  def mapping_function {range, offset}, num do
    case num in range do
      false -> :not_in_range
      true -> num + offset
    end
  end

  def mapping_function_builder map_tree do
    fn num ->
      case mapping_function(map_tree, num) do
        :not_in_range -> num
        value -> value
      end
    end
  end

  def map_tree_builder maps do
    mega_range = maps |> Enum.map(fn {range, _offset} -> range end) |> mega_range_builder

    case maps do
      [elem] -> elem
      _ ->
        # sort maps by range start
        maps = maps
          |> Enum.sort(fn {range_a, _offset_a}, {range_b, _offset_b} -> Enum.at(range_a, 0) < Enum.at(range_b, 0) end)

        # split list in half
        {maps_l, maps_r} = maps |> Enum.split(Enum.count(maps) |> div(2))

        tree_l = maps_l |> map_tree_builder
        tree_r = maps_r |> map_tree_builder

        {mega_range, tree_l, tree_r}
    end
  end

  def parse_map map do
    [title | map] = map |> String.split("\n")

    [from, _, to] = title
      |> String.slice(0..-6) # trim " map:" from end
      |> String.split("-")

    map_fn = map |> Enum.map(&parse_line/1) |> map_tree_builder |> mapping_function_builder

    %{{from, to} => map_fn}
  end

  def get_maps do
    File.read!("input.txt")
      |> String.split("\n\n")
      |> Enum.drop(1)
      |> Enum.map(&parse_map/1)
      |> Enum.reduce(%{}, fn map, acc -> Map.merge(map, acc) end)
  end

  def find_prev_map maps, {from, _to} do
    maps |> Enum.filter(fn {{_prev_from, prev_to}, _map} -> prev_to == from end) |> Enum.at(0)
  end

  def merge_maps map_a, map_b do
    {{_from_a, to}, map_fn_a} = map_a
    {{from, _to_b}, map_fn_b} = map_b

    merged_map_fn = fn num ->
      # map_fn_b.(map_fn_a.(num)).
      num |> map_fn_a.() |> map_fn_b.()
    end

    {{from, to}, merged_map_fn}
  end

  def compact_maps maps do
    case maps |> Map.keys() do
      [_single_key] -> maps # there is only one map so we are already compacted
      _ -> maps
        |> Enum.reduce(maps, fn {key, _map_fn}, acc ->
          map_fn = acc |> Map.get(key)
          prev_map = find_prev_map(acc, key)

          cond do
            map_fn == nil -> acc # current map have been merged already
            prev_map == nil -> acc # there is no prev map so we are in the first one

            true ->
              {merged_key, merged_map_fn} = merge_maps({key, map_fn}, prev_map)

              acc
                |> Map.pop(key) |> elem(1)
                |> Map.pop(prev_map |> elem(0)) |> elem(1)
                |> Map.put(merged_key, merged_map_fn)
          end

        end)
        |> compact_maps # do it again until we have only one map
    end
  end

  def is_in_ranges? num, ranges do
    ranges |> Enum.any?(fn range -> num in range end)
  end
end

map = Day5.get_maps
  |> Day5.compact_maps
  |> Map.values
  |> Enum.at(0)

seeds = Day5.get_seeds



1..100000000
  |> Task.async_stream(fn num ->
    valid? = map
      |> apply([num])
      |> Day5.is_in_ranges?(seeds)

    case valid? do
      true -> num
      false -> nil
    end
  end)
  |> Enum.find(fn {_state, result} -> result != nil end)
  |> elem(1)
  |> IO.puts
