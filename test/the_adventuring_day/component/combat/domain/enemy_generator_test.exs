defmodule TheAdventuringDay.Component.Combat.Domain.EnemyGeneratorTest do
  use TheAdventuringDay.DataCase
  use ExUnitProperties

  alias TheAdventuringDay.Component.Combat.Domain.EnemyGenerator
  alias TheAdventuringDay.Component.Combat.Domain.EnemyGenerator.GeneratedEnemyTemplate

  @repo Application.compile_env!(:the_adventuring_day, :enemy_template_spec_repo)

  @group_size [4, 5, 6]

  test "cannot generate enemies for invalid group sizes" do
    assert EnemyGenerator.generate_enemies(-1) == {:error, :invalid_group_size}
    assert EnemyGenerator.generate_enemies(0)  == {:error, :invalid_group_size}
    assert EnemyGenerator.generate_enemies(8)  == {:error, :invalid_group_size}
    assert EnemyGenerator.generate_enemies(9)  == {:error, :invalid_group_size}
    assert EnemyGenerator.generate_enemies(10) == {:error, :invalid_group_size}
  end

  test "generates enemies with exact minimum budget" do
    simple_spec()
    |> Enum.map(&(@repo.insert_enemy_template_spec(&1)))

    {:ok, template} = EnemyGenerator.generate_enemies(4)

    assert template == %GeneratedEnemyTemplate{
      available_budget: 5,
      budget_used: 4.5,
      template: [
        %{amount: 1.0, role: :skirmisher, level: :same_level, type: :standard},
        %{amount: 2.0, role: :troop, level: :one_level_lower, type: :standard},
        %{amount: 1.0, role: :wrecker, level: :same_level, type: :double_strength},
      ]
    }
  end

  property "Generating enemies is always within -0.5 and 0.5 of the encounter budget" do
    check all(group_size <- member_of(@group_size)) do
      simple_spec()
      |> Enum.map(fn spec -> @repo.insert_enemy_template_spec(spec) end)

      {:ok, template} = EnemyGenerator.generate_enemies(group_size)

      budget_remaining = template.available_budget - template.budget_used

      assert budget_remaining >= -0.5 and budget_remaining <= 0.5,
        "Expected budget remaining (#{budget_remaining}) to be between -0.5 and 0.5; available (#{template.available_budget}), used (#{template.budget_used})"
    end
  end

  property "Generating enemies with restrictions never creates more than allowed of that type" do
    check all(group_size <- member_of(@group_size)) do
      restricted_spec()
      |> Enum.map(fn spec -> @repo.insert_enemy_template_spec(spec) end)

      {:ok, template} = EnemyGenerator.generate_enemies(group_size)

      enemy_amounts = template.template |> Enum.map(fn enemy -> enemy.amount end)

      assert enemy_amounts |> Enum.all?(fn amt -> amt <= 2 end),
        "Expected all enemy types to only have one of each"
    end
  end

    property "Generating wreckers with permutations always has them at double_strength or standard" do
    check all(group_size <- member_of(@group_size)) do
      permutation_spec()
      |> Enum.map(fn spec -> @repo.insert_enemy_template_spec(spec) end)

      {:ok, template} = EnemyGenerator.generate_enemies(group_size)

      wrecker_template =
        template.template
        |> Enum.filter(fn enemy -> enemy.role == :wrecker end)
        |> hd

      case wrecker_template.amount do
        1.0 ->
          assert wrecker_template.type == :double_strength,
            "Expected a single wrecker to be double strength, but was #{wrecker_template.type}"

        2.0 ->
          assert wrecker_template.type == :standard,
            "Expected two wreckers to be standard strength, but was #{wrecker_template.type}"
      end
    end
  end

  def simple_spec() do
    [
      %{
        min_budget_required: 4.5,
        template: [
          %{amount: 1, role: :skirmisher, level: :same_level,      type: :standard},
          %{amount: 2, role: :troop,      level: :one_level_lower, type: :standard},
          %{amount: 1, role: :wrecker,    level: :same_level,      type: :double_strength},
        ],
        addons: %{
          enemy_roles: [:archer, :blocker, :caster, :leader, :spoiler],
          enemy_levels: [:same_level, :one_level_lower],
          enemy_types: [:mook]
        },
        restrictions: [],
        permutations: []
      },
    ]
  end

  def restricted_spec() do
    [
      %{
        min_budget_required: 4,
        template: [
          %{amount: 1, role: :skirmisher, level: :same_level,      type: :standard},
          %{amount: 1, role: :troop,      level: :same_level,      type: :standard},
          %{amount: 1, role: :wrecker,    level: :same_level,      type: :double_strength},
        ],
        addons: %{
          enemy_roles: [:archer, :blocker, :caster, :leader, :spoiler],
          enemy_levels: [:same_level, :one_level_lower],
          enemy_types: [:mook]
        },
        restrictions: [
          %{max_size: 2, enemy_roles: [:leader, :blocker, :wrecker, :archer, :caster, :spoiler, :skirmisher, :troop]},
        ],
        permutations: [
          %{when: %{enemy_role: :wrecker, has_count: 2}, then: %{level: :same_level}}
        ]
      },
    ]
  end

  def permutation_spec() do
    [
      %{
        min_budget_required: 4,
        template: [
          %{amount: 1, role: :skirmisher, level: :same_level,      type: :standard},
          %{amount: 1, role: :troop,      level: :same_level,      type: :standard},
          %{amount: 1, role: :wrecker,    level: :same_level,      type: :double_strength},
        ],
        addons: %{
          enemy_roles: [:archer, :blocker, :caster, :leader, :spoiler],
          enemy_levels: [:same_level, :one_level_lower],
          enemy_types: [:mook]
        },
        restrictions: [
          %{max_size: 1, enemy_roles: [:leader]},
          %{max_size: 2, enemy_roles: [:wrecker]}
        ],
        permutations: [
          %{when_amount: 2, when_role: :wrecker, then_type: :standard}
        ]
      },
    ]
  end
end
