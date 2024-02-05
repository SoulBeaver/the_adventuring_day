defmodule TheAdventuringDayWeb.CombatHTML do
  use TheAdventuringDayWeb, :html

  embed_templates "combat_html/*"

  def format_enemy(enemy) do
    if enemy.type == :mook do
      mook_format(enemy)
    else
      standard_format(enemy)
    end
  end

  defp standard_format(enemy) do
    plural? = enemy.amount > 1

    "#{count(enemy.amount)}#{strength(enemy.type, plural?)} #{role(enemy.role, plural?)}"
  end

  defp mook_format(enemy) do
    plural? = enemy.amount > 1

    "#{count(enemy.amount)} #{role(enemy.role, false)} #{strength(enemy.type, plural?)}"
  end

  defp strength(enemy_type, plural?) do
    case {enemy_type, plural?} do
      {:double_strength, _} -> " large"
      {:triple_strength, _} -> " huge"
      {:elite, _} -> " elite"

      {:mook, false} -> " minion group"
      {:mook, true} -> " minion groups"

      {:weakling, false} -> " weakling"
      {:weakling, true} -> " weaklings"

      _ -> ""
    end
  end

  defp role(enemy_role, plural?) do
    " #{to_string(enemy_role)}#{if plural? do "s" end}"
  end

  def organize_terrain_features(terrain_features) do
    grouped_terrain_features =
      terrain_features
      |> Enum.group_by(&(&1.terrain_type))
      |> Enum.map(fn {_terrain_type, instances} ->
        instances |> hd |> Map.put(:amount, length(instances))
      end)

    grouped_terrain_features
  end

  def format_terrain_feature(terrain) do
    "#{count(terrain.amount)} zone(s) of #{to_string(terrain.terrain_type)} terrain like #{terrain_examples(terrain.exterior_examples)}"
  end

  defp terrain_examples(terrain_examples) do
    terrain_examples
    |> Enum.join(", ")
  end

  defp count(amount) do
    case trunc(amount) do
      1 -> "One"
      2 -> "Two"
      3 -> "Three"
      4 -> "Four"
      5 -> "Five"
      6 -> "Six"
      7 -> "Seven"
      8 -> "Eight"
      9 -> "Nine"
      _ -> raise("Expected an amount between 1-9, but got #{amount}")
    end
  end
end
