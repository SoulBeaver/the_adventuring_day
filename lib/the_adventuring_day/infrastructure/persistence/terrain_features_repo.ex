defmodule TheAdventuringDay.Infrastructure.Persistence.TerrainFeaturesRepo do
  @moduledoc """
  TODO
  """

  import Ecto.Query

  alias TheAdventuringDay.Component.Combat.Domain.TerrainFeatures
  alias TheAdventuringDay.Repo

  @spec insert_terrain_feature!(map()) :: TerrainFeatures.t()
  def insert_terrain_feature!(params) do
    %TerrainFeatures{}
    |> TerrainFeatures.changeset(params)
    |> Repo.insert!()
  end

  @spec insert_terrain_feature(map()) :: {:ok, TerrainFeatures.t()} | {:error, Ecto.Changeset.t()}
  def insert_terrain_feature(params) do
    %TerrainFeatures{}
    |> TerrainFeatures.changeset(params)
    |> Repo.insert()
  end

  @spec random_terrain_feature() :: TerrainFeatures.t()
  def random_terrain_feature() do
    from(ets in TerrainFeatures,
      where: true,
      order_by: fragment("RANDOM()"),
      limit: 1
    )
    |> Repo.one!()
  end

  def truncate() do
    Repo.query("TRUNCATE terrain_features")
  end
end
