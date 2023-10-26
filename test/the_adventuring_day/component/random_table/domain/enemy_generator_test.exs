defmodule TheAdventuringDay.Component.RandomTable.Domain.EnemyGeneratorTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias TheAdventuringDay.Component.RandomTable.Domain.EnemyGenerator
  alias TheAdventuringDay.Component.RandomTable.Domain.EnemyGenerator.EnemyTemplate

  test "cannot generate enemies for invalid group sizes" do
    assert EnemyGenerator.generate_enemies(-1) == {:error, :invalid_group_size}
    assert EnemyGenerator.generate_enemies(0)  == {:error, :invalid_group_size}
    assert EnemyGenerator.generate_enemies(8)  == {:error, :invalid_group_size}
    assert EnemyGenerator.generate_enemies(9)  == {:error, :invalid_group_size}
    assert EnemyGenerator.generate_enemies(10) == {:error, :invalid_group_size}
  end

  test "generates enemies with exact minimum budget" do
    {:ok, template} = EnemyGenerator.generate_enemies(4)

    assert template == %EnemyTemplate{
      available_budget: 5,
      budget_used: 4.5,
      template: [
        %{amount: 1, role: :skirmisher, level: :same_level, type: :standard},
        %{amount: 2, role: :troop, level: :one_level_lower, type: :standard},
        %{amount: 1, role: :wrecker, level: :same_level, type: :double_strength},
      ]
    }
  end

  test "generates additional enemies" do
    {:ok, template} = EnemyGenerator.generate_enemies(5)

    assert template == %EnemyTemplate{
      available_budget: 7,
      budget_used: 6.5,
      template: [
        %{amount: 1, role: :skirmisher, level: :same_level, type: :standard},
        %{amount: 2, role: :troop, level: :one_level_lower, type: :standard},
        %{amount: 1, role: :wrecker, level: :same_level, type: :double_strength},
      ]
    }
  end

  @group_size [4, 5, 6]

  property "Generating enemies is always within -0.5 and 0.5 of the encounter budget" do
    check all(
      group_size <- member_of(@group_size)
    ) do
      {:ok, template} = EnemyGenerator.generate_enemies(group_size)

      budget_remaining = template.available_budget - template.budget_used

      assert budget_remaining >= -0.5 and budget_remaining <= 0.5,
        "Expected budget remaining (#{budget_remaining}) to be between -0.5 and 0.5; available (#{template.available_budget}), used (#{template.budget_used})"
    end
  end
end
