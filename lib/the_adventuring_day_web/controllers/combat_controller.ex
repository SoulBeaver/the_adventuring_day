defmodule TheAdventuringDayWeb.CombatController do
  use TheAdventuringDayWeb, :controller

  alias TheAdventuringDay.Component.Combat.DomainService.CombatGenerator
  alias TheAdventuringDay.Component.Combat.DomainService.HazardFeatureGenerator
  alias TheAdventuringDay.Component.Combat.DomainService.TerrainFeatureGenerator

  # defparams encounter_details %{
  #   party_members!: :integer,
  #   encounter_difficulty!: [field: Ecto.Enum, values: [:easy, :medium, :hard]],
  #   environs: [field: Ecto.Enum, values: [:indoor, :outdoor]],
  #   complexity: [field: Ecto.Enum, values: [:simple, :complex]]
  # }

  def generate(conn, params) do
    {:ok, encounter} = CombatGenerator.generate(:medium, :outdoor, 4)
    render(conn, :new_encounter, encounter: encounter)
  end

  def new_hazard(conn, _params) do
    {:ok, hazard} = HazardFeatureGenerator.generate_hazard_features(1)
    render(conn, :new_hazard, hazard: hazard |> hd)
  end

  def new_terrain_feature(conn, _params) do
    {:ok, terrain_feature} = TerrainFeatureGenerator.generate_terrain_features(1)
    render(conn, :new_terrain_feature, terrain_feature: terrain_feature |> hd)
  end
end
