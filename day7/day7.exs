defmodule Day7 do
  def parse_line line do
    [hand, bid] = line |> String.split(" ")

    {
      hand |> String.to_charlist,
      bid |> String.to_integer
    }
  end

  def get_hands do
    File.read!("input.txt")
      |> String.split("\n")
      |> Enum.map(&parse_line/1)
  end

  defmodule Hand do
    defp is_n_of_a_kind? hand, n do
      hand
        |> Enum.group_by(& &1)
        |> Enum.any?(fn {_, list} -> list |> Enum.count == n end)
    end

    defp is_n_pair?(hand, n) do
      hand
        |> Enum.group_by(& &1)
        |> Enum.filter(fn {_, list} -> list |> Enum.count == 2 end)
        |> Enum.count == n
    end

    def is_five_of_a_kind?(hand), do: hand |> is_n_of_a_kind?(5)

    def is_four_of_a_kind?(hand), do: hand |> is_n_of_a_kind?(4)

    def is_full_house?(hand), do: is_n_of_a_kind?(hand, 3) && is_n_of_a_kind?(hand, 2)

    def is_three_of_a_kind?(hand), do: hand |> is_n_of_a_kind?(3)

    def is_two_pair?(hand), do: hand |> is_n_pair?(2)

    def is_one_pair?(hand), do: hand |> is_n_pair?(1)

    def is_high_card?(_hand), do: true


    def get_hand_type_score hand do
      [
        &is_five_of_a_kind?/1,
        &is_four_of_a_kind?/1,
        &is_full_house?/1,
        &is_three_of_a_kind?/1,
        &is_two_pair?/1,
        &is_one_pair?/1,
        &is_high_card?/1
      ]
        |> Enum.map(& &1.(hand))
        |> Enum.find_index(& &1)
        |> Kernel.*(-1)
    end

    def get_relative_strength card do
      [?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?T, ?J, ?Q, ?K, ?A]
        |> Enum.find_index(& &1 == card)
    end

    def is_hand_better? hand1, hand2 do
      hand1_score = get_hand_type_score(hand1)
      hand2_score = get_hand_type_score(hand2)

      if hand1_score == hand2_score do
        hand1 |> Enum.map(&get_relative_strength/1)
        >
        hand2 |> Enum.map(&get_relative_strength/1)
      else
        hand1_score > hand2_score
      end
    end
  end

  def sort_hands hands do
    hands
      |> Enum.sort(fn {hand1, _bid1}, {hand2, _bid2} -> Hand.is_hand_better?(hand1, hand2) end)
      |> Enum.reverse
  end
end

Day7.get_hands
  |> Day7.sort_hands
  |> Enum.with_index(1) # index is the rank
  |> Enum.map(fn {{_hand, bid}, rank} -> bid * rank end)
  |> Enum.sum
  |> IO.puts
