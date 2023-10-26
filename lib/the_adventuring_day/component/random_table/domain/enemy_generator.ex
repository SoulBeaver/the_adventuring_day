defmodule TheAdventuringDay.Component.RandomTable.Domain.EnemyGenerator do
  @moduledoc """
  TODO rename monster to enemy
  """

  defmodule EnemyTemplate do
    defstruct available_budget: 0,
            budget_used: 0,
            template: []

    @type t :: %__MODULE__{
      available_budget: pos_integer(),
      budget_used: pos_integer(),
      template: list(enemy())
    }

    @type enemy :: %{
      amount: pos_integer(),
      role: enemy_role(),
      level: enemy_level(),
      type: enemy_type()
    }

    @type enemy_role() :: :archer | :blocker | :caster | :leader | :spoiler | :troop | :wrecker
    @type enemy_level() :: :same_level | :one_level_higher | :one_level_lower | :two_levels_higher | :two_levels_lower
    @type enemy_type() :: :standard | :double_strength | :triple_strength | :mook | :elite | :weakling
  end

  @enemy_roles [:archer, :blocker, :caster, :leader, :spoiler, :troop, :wrecker]
  @enemy_levels [:same_level, :one_level_higher, :one_level_lower]
  @enemy_types [:standard, :double_strength, :triple_strength, :mook, :elite, :weakling]

  # def generate_enemies(complexity, difficulty, group_size)
  @spec generate_enemies(pos_integer()) :: {:ok, EnemyTemplate.t()} | {:error, term()}
  def generate_enemies(group_size)

  def generate_enemies(group_size) when group_size <= 0 or group_size > 7 do
    {:error, :invalid_group_size}
  end

  def generate_enemies(group_size) do
    available_enemy_budget = available_enemy_budget_for(group_size)

    template =
      enemy_templates()
      |> Enum.filter(fn template -> template.min_budget_required <= available_enemy_budget end)
      |> Enum.random()

    budget_remaining = available_enemy_budget - template.min_budget_required

    completed_template = add_more_enemies(template, budget_remaining)

    {:ok, %EnemyTemplate{
      available_budget: available_enemy_budget,
      budget_used: budget_used(completed_template, group_size),
      template: completed_template.template
    }}
  end

  defp budget_used(template, group_size) do
    available_enemy_budget = available_enemy_budget_for(group_size)

    budget_used =
      template.template
      |> Enum.map(fn enemy -> enemy_budget_cost_for(enemy) * enemy.amount end)
      |> Enum.sum()

     budget_used
  end

  # scenario: no addons
  # scenario: template with 4 enemies
  # scenario: template with 2 enemies (solo + minions?)
  defp enemy_templates() do
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
        restrictions: [
          %{max_size: 1, enemy_types: [:leader, :blocker]},
          %{max_size: 2, enemy_types: [:wrecker]}
        ],
        permutations: [
          %{when: %{enemy_type: :wrecker, has_count: 2}, then: %{enemy_level: :one_level_lower}}
        ]
      },
    ]
  end

  defp available_enemy_budget_for(4), do: 5
  defp available_enemy_budget_for(5), do: 7
  defp available_enemy_budget_for(6), do: 9
  defp available_enemy_budget_for(7), do: 11
  defp available_enemy_budget_for(group_size) when group_size < 4, do: group_size

  defp add_more_enemies(template, available_budget) when available_budget <= 0.5 do
    template
  end

  defp add_more_enemies(template, available_budget) do
    # completed_template =
    #   template
    #   |> maybe_add_new_monster_step()
    #   |> maybe_increase_monster_count()
    #   |> apply_permutations()

    completed_template =
      case length(template.template) do
        2 ->
          if :rand.uniform(100) > 25 do
            add_new_enemy(template, available_budget, generate_enemy(template.addons))
          else
            add_duplicate_enemies(template, available_budget)
          end

        3 ->
          if :rand.uniform(100) > 50 do
            add_new_enemy(template, available_budget, generate_enemy(template.addons))
          else
            add_duplicate_enemies(template, available_budget)
          end

        4 ->
          add_duplicate_enemies(template, available_budget)
      end

    completed_template
  end

  defp add_new_enemy(template, available_budget, additional_enemy) do
    updated_template = %{template | template: [additional_enemy | template.template]}
    budget_remaining = available_budget - enemy_budget_cost_for(additional_enemy)

    add_duplicate_enemies(updated_template, budget_remaining)
  end

  defp add_duplicate_enemies(template, available_budget) when available_budget <= 0.5 do
    template
  end

  defp add_duplicate_enemies(template, available_budget) do
    duplicated_enemy =
      template.template
      |> Enum.random()
      |> Map.update!(:amount, &(&1+1))

    other_enemies =
      template.template
      |> Enum.filter(fn enemy -> not are_enemies_equal(enemy, duplicated_enemy) end)

    updated_template = %{template | template: [duplicated_enemy | other_enemies]}
    budget_remaining = available_budget - enemy_budget_cost_for(duplicated_enemy)

    if is_within_threshold(budget_remaining) do
      add_duplicate_enemies(updated_template, budget_remaining)
    else
      add_duplicate_enemies(template, available_budget) # try, try again
    end
  end

  defp is_within_threshold(budget_remaining) do
    budget_remaining >= -0.5
  end

  defp are_enemies_equal(enemy_a, enemy_b) do
    enemy_a.role == enemy_b.role &&
    enemy_a.level == enemy_b.level &&
    enemy_a.type == enemy_b.type
  end

  defp generate_enemy(%{enemy_roles: enemy_roles, enemy_levels: enemy_levels, enemy_types: enemy_types}) do
    role = enemy_roles |> Enum.random()
    enemy_level = enemy_levels |> Enum.random()
    enemy_type =
      if :rand.uniform(100) > 90 do
        enemy_types |> Enum.random()
      else
        :standard
      end

    %{amount: 1, role: role, level: enemy_level, type: enemy_type}
  end

  defp enemy_budget_cost_for(%{amount: _amount, role: _role, level: level, type: type}) do
    enemy_level_and_type_reference(level, type)
  end

  defp enemy_level_and_type_reference(:same_level, :standard), do: 1
  defp enemy_level_and_type_reference(:same_level, :elite), do: 1.5
  defp enemy_level_and_type_reference(:same_level, :double_strength), do: 2
  defp enemy_level_and_type_reference(:same_level, :triple_strength), do: 3
  defp enemy_level_and_type_reference(:same_level, :weakling), do: 0.5
  defp enemy_level_and_type_reference(:same_level, :mook), do: 1

  defp enemy_level_and_type_reference(:one_level_higher, :standard), do: 1.5
  defp enemy_level_and_type_reference(:one_level_higher, :elite), do: 2
  defp enemy_level_and_type_reference(:one_level_higher, :double_strength), do: 3
  defp enemy_level_and_type_reference(:one_level_higher, :triple_strength), do: 4
  defp enemy_level_and_type_reference(:one_level_higher, :weakling), do: 1
  defp enemy_level_and_type_reference(:one_level_higher, :mook), do: 1.5

  defp enemy_level_and_type_reference(:one_level_lower, :standard), do: 0.75
  defp enemy_level_and_type_reference(:one_level_lower, :elite), do: 1
  defp enemy_level_and_type_reference(:one_level_lower, :double_strength), do: 1.5
  defp enemy_level_and_type_reference(:one_level_lower, :triple_strength), do: 2
  defp enemy_level_and_type_reference(:one_level_lower, :weakling), do: 0.5
  defp enemy_level_and_type_reference(:one_level_lower, :mook), do: 0.75
end
