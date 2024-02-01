defmodule TheAdventuringDay.Component.Combat.DomainService.CombatGenerator do
  @moduledoc """
  TODO
  """

  alias TheAdventuringDay.Component.Combat.DomainService.EnemyGenerator
  alias TheAdventuringDay.Component.Combat.DomainService.HazardFeatureGenerator
  alias TheAdventuringDay.Component.Combat.DomainService.TerrainFeatureGenerator

  @type t() :: %__MODULE__{
    enemies: EnemyGenerator.GeneratedEnemyTemplate.t(),
    terrain_features: list(TerrainFeatureGenerator.GeneratedTerrainFeature.t()),
    hazard_features: list(HazardFeatureGenerator.GeneratedHazardFeature.t())
  }

  defstruct enemies: [],
            terrain_features: [],
            hazard_features: []

  @type difficulty :: :easy | :medium | :hard | :deadly
  @type environment :: :indoor | :outdoor
  @type complexity :: :simple | :complex
  @type realism :: :grounded | :epic | :gonzo
  @type group_size :: pos_integer()

  # def generate(complexity, realism, difficulty, environment, group_size)
  @spec generate(difficulty(), environment(), group_size()) :: t() | {:error, term()}
  def generate(_difficulty, _environment, group_size) do
    with {:ok, enemies} <- EnemyGenerator.generate_enemies(group_size),
         {:ok, terrain_features} <- TerrainFeatureGenerator.generate_terrain_features(),
         {:ok, hazards} <- HazardFeatureGenerator.generate_hazard_features()
    do
      {:ok, %__MODULE__{
        :enemies => enemies,
        :terrain_features => terrain_features,
        :hazard_features => hazards
      }}
    end
  end
end
