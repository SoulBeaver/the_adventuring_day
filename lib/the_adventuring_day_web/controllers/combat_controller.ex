defmodule TheAdventuringDayWeb.CombatController do
  @moduledoc """
  TODO
  """

  use TheAdventuringDayWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias TheAdventuringDayWeb.Schemas
  alias TheAdventuringDay.Component.Combat.DomainService.CombatGenerator
  alias TheAdventuringDay.Component.Combat.DomainService.HazardFeatureGenerator
  alias TheAdventuringDay.Component.Combat.DomainService.TerrainFeatureGenerator
  alias TheAdventuringDay.Infrastructure.Persistence.CombatEncounterRepo

  action_fallback UpdatedPhxWeb.FallbackController

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  tags ["combat"]

  operation :generate,
    summary: "Generate combat encounter",
    description: "Generates a new combat encounter based on the parameters provided.",
    request_body: {"Combat encounter attributes", "application/json", Schemas.CombatEncounterRequest, required: true},
    responses: %{
      422 => OpenApiSpex.JsonErrorResponse.response(),
      ok: {"Combat Encounter Response", "application/json", Schemas.CombatEncounterResponse}
    }

  def generate(
        %{
          body_params: %Schemas.CombatEncounterRequest{
            party_members: party_members,
            encounter_difficulty: encounter_difficulty,
            environs: environs,
            complexity: _complexity
          }
        } = conn,
        _params
      ) do
    {:ok, encounter} = CombatGenerator.generate(encounter_difficulty, environs, party_members)
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
    request_body:
      {"Combat encounter attributes", "application/json", Schemas.PersistCombatEncounterRequest, required: true},
    responses: %{
      422 => OpenApiSpex.JsonErrorResponse.response(),
      ok: {"CombatEncounter Response", "application/json", Schemas.CombatEncounterResponse}
    }

  def save(
        conn = %{
          body_params: %Schemas.PersistCombatEncounterRequest{
            encounter: %Schemas.CombatEncounter{
              enemies: %Schemas.Enemies{
                available_budget: available_budget,
                budget_used: budget_used,
                template: template
              },
              terrain_features: terrain_features,
              hazards: hazards
            }
          }
        },
        _params
      ) do
    encounter_params = %{
      person_id: Map.get(conn.assigns.person, :id),
      enemies: %{
        available_budget: available_budget,
        budget_used: budget_used,
        template: template |> Enum.map(&Map.from_struct/1)
      },
      terrain_features: terrain_features |> Enum.map(&Map.from_struct/1),
      hazards: hazards |> Enum.map(&Map.from_struct/1)
    }

    with {:ok, saved_encounter} = CombatEncounterRepo.insert_combat_encounter(encounter_params) do
      render(conn, :show, encounter: saved_encounter)
    end
  end

  operation :show,
    summary: "Show a saved encounter",
    description: "Shows a previously saved combat encounter if it exists and the user was the one who saved it.",
    parameters: [
      id: [in: :path, type: :integer, description: "Combat Encounter ID"]
    ],
    responses: %{
      ok: {"CombatEncounter Response", "application/json", Schemas.CombatEncounterResponse}
    }

  def show(conn, %{id: combat_encounter_id}) do
    person_id = Map.get(conn.assigns.person, :id)

    encounter = CombatEncounterRepo.get_combat_encounter!(combat_encounter_id, person_id)
    render(conn, :show, encounter: encounter)
  end
end
