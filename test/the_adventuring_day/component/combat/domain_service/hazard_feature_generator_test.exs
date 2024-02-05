defmodule TheAdventuringDay.Component.Combat.DomainService.HazardFeatureGeneratorTest do
  use TheAdventuringDay.DataCase
  use ExUnitProperties

  alias TheAdventuringDay.Component.Combat.DomainService.HazardFeatureGenerator
  alias TheAdventuringDay.Infrastructure.Persistence.HazardFeaturesRepo

  test "Generates a valid hazard" do
    single_hazard()

    {:ok, hazards} = HazardFeatureGenerator.generate_hazard_features(1)

    assert (hazards |> hd) == %HazardFeatureGenerator.GeneratedHazardFeature{
      hazard_type: :trap,
      name: "Sawblade trap",
      description: """
      There are sawblades in the walls, floor or ceiling. Stepping on a pressure plate activates the sawblades and slice through whatever's in their path.
      """
    }
  end

  test "Never returns a duplicate hazard" do
    single_hazard()

    {:ok, hazards} = HazardFeatureGenerator.generate_hazard_features(4)

    assert length(hazards) == 1
  end

  defp single_hazard() do
    HazardFeaturesRepo.truncate()
    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :trap,
      name: "Sawblade trap",
      description: """
      There are sawblades in the walls, floor or ceiling. Stepping on a pressure plate activates the sawblades and slice through whatever's in their path.
      """
    })
  end
end
