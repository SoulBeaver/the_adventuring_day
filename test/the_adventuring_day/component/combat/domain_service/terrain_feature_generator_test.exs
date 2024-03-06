defmodule TheAdventuringDay.Component.Combat.DomainService.TerrainFeatureGeneratorTest do
  use TheAdventuringDay.DataCase
  use ExUnitProperties

  alias TheAdventuringDay.Component.Combat.DomainService.TerrainFeatureGenerator
  alias TheAdventuringDay.Infrastructure.Persistence.TerrainFeaturesRepo

  test "Generates a valid terrain feature" do
    single_terrain_feature()

    {:ok, terrain_feature} = TerrainFeatureGenerator.generate_terrain_features(1)

    assert terrain_feature |> hd == %TerrainFeatureGenerator.GeneratedTerrainFeature{
             terrain_type: :difficult,
             name: "Difficult terrain",
             description: """
             Difficult terrain slows down characters without blocking line of sight. In encounter design, difficult terrain is a useful tool to make a path less appealing without removing it as an option. It gives you some of the benefits of walls and other terrain that blocks movement without the drawback of constricting the party's options.
             """,
             interior_examples: ["Rubble", "Uneven ground", "Steep slope", "Oil slick"],
             exterior_examples: [
               "Rubble",
               "Uneven ground",
               "Shallow water",
               "Fallen trees",
               "Steep slope",
               "Mud",
               "Thick undergrowth",
               "Dense vines"
             ]
           }
  end

  defp single_terrain_feature() do
    TerrainFeaturesRepo.truncate()

    TerrainFeaturesRepo.insert_terrain_feature!(%{
      terrain_type: :difficult,
      name: "Difficult terrain",
      description: """
      Difficult terrain slows down characters without blocking line of sight. In encounter design, difficult terrain is a useful tool to make a path less appealing without removing it as an option. It gives you some of the benefits of walls and other terrain that blocks movement without the drawback of constricting the party's options.
      """,
      interior_examples: ["Rubble", "Uneven ground", "Steep slope", "Oil slick"],
      exterior_examples: [
        "Rubble",
        "Uneven ground",
        "Shallow water",
        "Fallen trees",
        "Steep slope",
        "Mud",
        "Thick undergrowth",
        "Dense vines"
      ]
    })
  end
end
