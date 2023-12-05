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

get_card_win_count = fn {id, winning_numbers, actual_numbers} ->
  win_count = actual_numbers
    |> Enum.filter(fn num -> num in winning_numbers end)
    |> length

  {id, win_count}
end

cards_won = fn {id, count} ->
  cards_won = case count do
    0 -> []
    _ -> (id + 1)..(id + count) |> Enum.to_list
  end

  {id, cards_won}
end

defmodule Day4 do

  def ids_to_cards  cards, ids do
    ids |> Enum.map(fn id -> cards |> Enum.at(id - 1) end)
  end

  def with_won_cards cards, all_cards do
    case cards do
      [] -> []
      _ -> cards
      |> Enum.map(fn {id, cards_won} -> {id, ids_to_cards(all_cards, cards_won)} end)
      |> Enum.map(fn {id, cards_won} -> {id, with_won_cards(cards_won, all_cards)} end)
      |> Enum.flat_map(fn {id, cards_won} -> [id | cards_won] end)
    end
  end

  def with_won_cards cards do
    cards |> with_won_cards(cards)
  end
end

File.read("input.txt")
  |> elem(1)
  |> String.split("\n")
  |> Enum.map(parse_game_line)
  |> Enum.map(get_card_win_count)
  |> Enum.map(cards_won)
  |> Day4.with_won_cards
  |> length
  |> IO.puts
