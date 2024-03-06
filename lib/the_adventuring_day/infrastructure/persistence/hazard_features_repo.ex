defmodule TheAdventuringDay.Infrastructure.Persistence.HazardFeaturesRepo do
  @moduledoc """
  TODO
  """

  import Ecto.Query

  alias TheAdventuringDay.Component.Combat.Domain.HazardFeatures
  alias TheAdventuringDay.Repo

  @spec insert_hazard_feature!(map()) :: HazardFeatures.t()
  def insert_hazard_feature!(params) do
    %HazardFeatures{}
    |> HazardFeatures.changeset(params)
    |> Repo.insert!()
  end

  @spec insert_hazard_feature(map()) :: {:ok, HazardFeatures.t()} | {:error, Ecto.Changeset.t()}
  def insert_hazard_feature(params) do
    %HazardFeatures{}
    |> HazardFeatures.changeset(params)
    |> Repo.insert()
  end

  @spec random_hazard_features(pos_integer()) :: HazardFeatures.t()
  def random_hazard_features(amount) do
    from(ets in HazardFeatures,
      where: true,
      order_by: fragment("RANDOM()"),
      limit: ^amount
    )
    |> Repo.all()
  end

  def truncate() do
    Repo.query("TRUNCATE hazard_features")
  end
end
