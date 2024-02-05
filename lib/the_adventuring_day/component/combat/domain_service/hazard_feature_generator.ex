defmodule TheAdventuringDay.Component.Combat.DomainService.HazardFeatureGenerator do
  @moduledoc """
  TODO
  """

  alias TheAdventuringDay.Component.Combat.Domain.HazardFeatures

  defmodule GeneratedHazardFeature do
    @type t() :: %__MODULE__{
      hazard_type: HazardFeatures.terrain_type(),
      name: String.t(),
      description: String.t()
    }

    defstruct hazard_type: :trap,
              name: "",
              description: ""
  end

  @doc """
  TODO
  """
  @spec generate_hazard_features(pos_integer()) :: {:ok, list(GeneratedHazardFeature.t())} | {:error, term()}
  def generate_hazard_features(max_hazard_features \\ 4)

  def generate_hazard_features(max_hazard_features) when max_hazard_features <= 0 do
    {:error, :invalid_max_hazard_features}
  end

  def generate_hazard_features(max_hazard_features) do
    hazards =
      :rand.uniform(max_hazard_features)
      |> random_hazard_features()
      |> Enum.uniq_by(&(&1.id))
      |> Enum.map(&sanitize_template/1)

    {:ok, hazards}
  end

  defp random_hazard_features(amount) do
    repo = Application.get_env(:the_adventuring_day, :hazard_features_repo)

    repo.random_hazard_features(amount)
  end

  defp sanitize_template(template) do
    %GeneratedHazardFeature{
      hazard_type: template.hazard_type,
      name: template.name,
      description: template.description
    }
  end
end
