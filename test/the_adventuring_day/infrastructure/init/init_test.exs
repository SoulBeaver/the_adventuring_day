defmodule TheAdventuringDay.Infrastructure.Init.InitTest do
  use TheAdventuringDay.DataCase

  alias TheAdventuringDay.Infrastructure.Init.Init

  alias TheAdventuringDay.Repo
  alias TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpec
  alias TheAdventuringDay.Component.Combat.Domain.TerrainFeatures
  alias TheAdventuringDay.Component.Combat.Domain.HazardFeatures

  test "Initializes the database" do
    Init.seed_data()

    assert Repo.aggregate(EnemyTemplateSpec, :count, :id) == 6
    assert Repo.aggregate(TerrainFeatures, :count, :id) == 6
    assert Repo.aggregate(HazardFeatures, :count, :id) == 16
  end

  test "Initialization of the DB is idempotent" do
    Init.seed_data()
    Init.seed_data()
    Init.seed_data()

    assert Repo.aggregate(EnemyTemplateSpec, :count, :id) == 6
    assert Repo.aggregate(TerrainFeatures, :count, :id) == 6
    assert Repo.aggregate(HazardFeatures, :count, :id) == 16
  end
end
