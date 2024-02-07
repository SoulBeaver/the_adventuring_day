defmodule TheAdventuringDayWeb.CombatJSON do
  @moduledoc """
  TODO
  """

  def new_encounter(%{encounter: encounter}) do
    %{encounter: %{
      :enemies => Map.from_struct(encounter.enemies),
      :terrain_features => encounter.terrain_features |> Enum.map(&Map.from_struct/1),
      :hazards => encounter.hazard_features |> Enum.map(&Map.from_struct/1)
    }}
  end

  def show(%{encounter: encounter}) do
    enemies =
      %{encounter.enemies | template: encounter.enemies.template |> Enum.map(&Map.from_struct/1)}
      |> Map.from_struct()

    %{encounter: %{
      :id => encounter.id,
      :enemies => enemies,
      :terrain_features => encounter.terrain_features |> Enum.map(&Map.from_struct/1),
      :hazards => encounter.hazards |> Enum.map(&Map.from_struct/1)
    }}
  end

  def new_hazard(%{hazard: hazard}) do
    %{hazard: Map.from_struct(hazard)}
  end

  def new_terrain_feature(%{terrain_feature: terrain_feature}) do
    %{terrain_feature: Map.from_struct(terrain_feature)}
  end
end
