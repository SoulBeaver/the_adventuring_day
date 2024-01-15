defmodule TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpecTest do
  use TheAdventuringDay.DataCase
  require ExUnitProperties

  alias TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpec

  @repo Application.compile_env!(:the_adventuring_day, :enemy_template_spec_repo)

  @sample_size 1000

  test "Prefers creating mooks most of the time" do
    simple_spec()
    |> Enum.map(&@repo.insert_enemy_template_spec(&1))

    enemy_template_spec = @repo.random_enemy_template_spec(7)

    generated_enemies = 1..@sample_size |> Enum.map(fn _ -> EnemyTemplateSpec.generate_enemy(enemy_template_spec) end)

    mook_enemies = generated_enemies |> Enum.filter(fn enemy -> enemy.type == :mook end)

    # At least half or more generated enemies are mooks
    assert length(mook_enemies) > @sample_size / 2
  end

  def simple_spec() do
    [
      %{
        min_budget_required: 4.5,
        template: [
          %{amount: 1, role: :skirmisher, level: :same_level, type: :standard},
          %{amount: 2, role: :troop, level: :one_level_lower, type: :standard},
          %{amount: 1, role: :wrecker, level: :same_level, type: :double_strength}
        ],
        addons: %{
          enemy_roles: [:archer, :blocker, :caster, :leader, :spoiler],
          enemy_levels: [:same_level, :one_level_lower],
          enemy_types: [:mook]
        },
        restrictions: [],
        permutations: []
      }
    ]
  end
end
