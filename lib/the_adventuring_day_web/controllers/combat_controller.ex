defmodule TheAdventuringDayWeb.CombatController do
  use TheAdventuringDayWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.{Schema, Reference}

  alias TheAdventuringDayWeb.Schemas
  alias TheAdventuringDay.Component.Combat.DomainService.CombatGenerator
  alias TheAdventuringDay.Component.Combat.DomainService.HazardFeatureGenerator
  alias TheAdventuringDay.Component.Combat.DomainService.TerrainFeatureGenerator

  # defparams encounter_details %{
  #   party_members!: :integer,
  #   encounter_difficulty!: [field: Ecto.Enum, values: [:easy, :medium, :hard]],
  #   environs: [field: Ecto.Enum, values: [:indoor, :outdoor]],
  #   complexity: [field: Ecto.Enum, values: [:simple, :complex]]
  # }

  tags ["combat"]
  # security [%{}, %{"oauth" => ["user:email"]}]

  operation :generate,
    summary: "Generate combat encounter",
    description: "Generates a new combat encounter based on the parameters provided.",
    request_body:
      {"Combat encounter attributes", "application/json", Schemas.CombatEncounterRequest, required: true},
    responses: [
      ok: {"Combat Encounter Response", "application/json", Schemas.CombatEncounterResponse},
      bad_request: %Reference{"$ref": "#/components/responses/bad_request"}
    ]

  def generate(conn, params) do
    {:ok, encounter} = CombatGenerator.generate(:medium, :outdoor, 4)
    render(conn, :new_encounter, encounter: encounter)
  end

  operation :new_hazard,
  summary: "Generate a random hazard",
  description: "Generates a random hazard.",
  responses: [
    ok: {"Hazard Response", "application/json", Schemas.HazardResponse}
  ]

  def new_hazard(conn, _params) do
    {:ok, hazard} = HazardFeatureGenerator.generate_hazard_features(1)
    render(conn, :new_hazard, hazard: hazard |> hd)
  end

  operation :new_terrain_feature,
  summary: "Generate a random terrain feature",
  description: "Generates a random terrain feature.",
  responses: [
    ok: {"TerrainFeature Response", "application/json", Schemas.TerrainFeature}
  ]

  def new_terrain_feature(conn, _params) do
    {:ok, terrain_feature} = TerrainFeatureGenerator.generate_terrain_features(1)
    render(conn, :new_terrain_feature, terrain_feature: terrain_feature |> hd)
  end
end
