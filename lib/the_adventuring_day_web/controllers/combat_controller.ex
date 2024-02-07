defmodule TheAdventuringDayWeb.CombatController do
  @moduledoc """
  TODO
  """

  use TheAdventuringDayWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Reference

  alias TheAdventuringDayWeb.Schemas
  alias TheAdventuringDay.Component.Combat.DomainService.CombatGenerator
  alias TheAdventuringDay.Component.Combat.DomainService.HazardFeatureGenerator
  alias TheAdventuringDay.Component.Combat.DomainService.TerrainFeatureGenerator

  action_fallback UpdatedPhxWeb.FallbackController

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  tags ["combat"]
  # security [%{"JWT" => []}]

  operation :generate,
    summary: "Generate combat encounter",
    description: "Generates a new combat encounter based on the parameters provided.",
    request_body:
      {"Combat encounter attributes", "application/json", Schemas.CombatEncounterRequest, required: true},
    responses: [
      ok: {"Combat Encounter Response", "application/json", Schemas.CombatEncounterResponse},
      bad_request: %Reference{"$ref": "#/components/responses/bad_request"}
    ]

  def generate(conn, _params) do
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

  operation :save,
  summary: "Save the combat encounter",
  description: "Saves the combat encounter for the logged-in user.",
  responses: [
    ok: {"CombatEncounter Response", "application/json", Schemas.CombatEncounterResponse}
  ]

  def save(conn, _params) do
    {:ok, encounter} = CombatGenerator.generate(:medium, :outdoor, 4)
    render(conn, :new_encounter, encounter: encounter)
  end
end
