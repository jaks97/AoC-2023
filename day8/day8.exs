defmodule Day8 do
  defp parse_file do
    File.read!("input.txt")
      |> String.split("\n")
      |> Enum.filter(& &1 != "")
  end

  def get_instructions do
    [instructions_string | _network] = parse_file()

    instructions_string |> String.to_charlist
  end

  def get_network do
    [_instructions_string | network] = parse_file()

    network
      |> Enum.map(& &1 |> String.split(" = "))
      |> Enum.map(fn [root, lr] ->
        %{
          root =>
            (
              [l, r] = lr
                |> String.slice(1..-2) # trim the leading and trailing brackets
                |> String.split(", ")

              {l, r}
            )
        }
      end)
      |> Enum.reduce(%{}, fn map, acc -> Map.merge(map, acc) end)
  end

  defp get_next_node {l, r}, instruction do
    case instruction do
      ?L -> l
      ?R -> r
    end
  end

  def navigate_network {network, instructions} = tree, {root, position} \\ {"AAA", 0} do
    case root do
      "ZZZ" -> position
      _ ->
        instruction = instructions |> Enum.at(rem(position, length(instructions)))
        next_node = network[root] |> get_next_node(instruction)
        navigate_network(tree, {next_node, position + 1})
    end
  end
end

{Day8.get_network, Day8.get_instructions}
  |> Day8.navigate_network
  |> IO.puts
