defmodule TheAdventuringDay.Component.Combat.DomainService.TerrainFeatureGenerator do

  alias TheAdventuringDay.Component.Combat.Domain.TerrainFeatures

  defmodule GeneratedTerrainFeature do
    @type t() :: %__MODULE__{
      terrain_type: TerrainFeatures.terrain_type(),
      name: String.t(),
      description: String.t(),
      interior_examples: list(String.t()),
      exterior_examples: list(String.t())
    }

    defstruct terrain_type: :difficult,
              name: "Difficult terrain",
              description: "",
              interior_examples: [],
              exterior_examples: []
  end

  @doc """
  TODO
  """
  @spec generate_terrain_features(pos_integer()) :: {:ok, list(GeneratedTerrainFeature.t())} | {:error, term()}
  def generate_terrain_features(max_terrain_features \\ 4)

  def generate_terrain_features(max_terrain_features) when max_terrain_features <= 0 do
    {:error, :invalid_max_terrain_features}
  end

  def generate_terrain_features(max_terrain_features) do
    terrain_features =
      (1..:rand.uniform(max_terrain_features))
      |> Enum.map(fn _ -> random_terrain_feature() end)
      |> Enum.map(fn template -> sanitize_template(template) end)

    {:ok, terrain_features}
  end

  defp random_terrain_feature() do
    repo = Application.get_env(:the_adventuring_day, :terrain_features_repo)

    repo.random_terrain_feature()
  end

  defp sanitize_template(template) do
    %GeneratedTerrainFeature{
      terrain_type: template.terrain_type,
      name: template.name,
      description: template.description,
      interior_examples: template.interior_examples,
      exterior_examples: template.exterior_examples
    }
  end
end
