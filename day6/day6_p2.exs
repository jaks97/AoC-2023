defmodule Day6 do
  # T = Time presing the button
  # V = Speed
  # D = Distance traveled
  # Dr = Record distance
  # Tm = Race time
  #
  # V = T
  #
  # D = V * (Tm - T) = V*Tm - V*T = T*Tm - T^2
  #
  # This is a parabola, like ⌒, so it has two roots, which are the maximum and minimum time to wait to move 0 milimeters.
  # If I want to get the max and min time to wait to move an amount Dr, we should just move the parabola downwards Dr units and find the roots:
  #
  # -T^2 + T*Tm - Dr
  #
  # T0, T1 = [-Tm +- sqrt(Tm² - 4Dr)] / -2

  def get_best_times_to_hold_button {max_time, record_distance} do
    distance = record_distance + 1 # we need to beat the record

    sqrt = :math.sqrt(max_time * max_time - 4 * distance)

    t0 = (-max_time + sqrt) / -2 |> ceil
    t1 = (-max_time - sqrt) / -2 |> floor

    t0..t1
  end

  def get_races do
    File.read!("input.txt")
      |> String.split("\n")
      |> Enum.map(& &1 |> String.split(":"))
      |> Enum.map(fn [_name, values] -> values end)
      |> Enum.map(& &1 |> String.replace(" ", ""))
      |> Enum.map(&String.to_integer/1)
      |> (fn [a, b] -> {a, b} end).()
  end
end

Day6.get_races
  |> Day6.get_best_times_to_hold_button
  |> Range.size
  |> IO.puts
