defmodule EnemyTemplateSpecBuilders do
  defmacro __using__(_options) do
    quote do
      import EnemyTemplateSpecBuilders, only: :functions
    end
  end

  alias TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpec

  # scenario: no addons
  # scenario: template with 4 enemies
  # scenario: template with 2 enemies (solo + minions?)
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
        restrictions: [
          %{max_size: 1, enemy_roles: [:leader, :blocker]},
          %{max_size: 2, enemy_roles: [:wrecker]}
        ],
        permutations: [
          %{when: %{enemy_role: :wrecker, has_count: 2}, then: %{enemy_level: :one_level_lower}}
        ]
      }
    ]
  end
end
