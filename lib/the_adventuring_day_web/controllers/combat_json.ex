defmodule TheAdventuringDayWeb.CombatJSON do
  @moduledoc """
  TODO
  """

  alias TheAdventuringDay.Component.Combat.DomainService.EnemyGenerator.GeneratedEnemyTemplate

  def new_encounter(%{encounter: encounter}) do
    %{encounter: %{
      :enemies => Map.from_struct(encounter.enemies),
      :terrain_features => encounter.terrain_features |> Enum.map(&Map.from_struct/1),
      :hazards => encounter.hazard_features |> Enum.map(&Map.from_struct/1)
    }}
  end

  def new_hazard(%{hazard: hazard}) do
    %{hazard: Map.from_struct(hazard)}
  end

  def new_terrain_feature(%{terrain_feature: terrain_feature}) do
    %{terrain_feature: Map.from_struct(terrain_feature)}
  end

  def error(reason) do
    %{error: "Could not complete request", reason: reason}
  end

  # available_budget: 5, budget_used: 5.5, template: [%{amount: 1, level: :same_level, role: :leader, type: :standard}, %{amount: 1.0, level: :same_level, role: :skirmisher, type: :standard}, %{amount: 2.0, level: :one_level_lower, role: :troop, type: :standard}, %{amount: 1.0, level: :same_level, role: :wrecker, type: :double_strength}]

  def data(%GeneratedEnemyTemplate{} = template) do
    %{

    }
  end
end
