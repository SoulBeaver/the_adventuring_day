defmodule TheAdventuringDay.Component.Combat.Domain.EnemyGenerator do
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

  defstruct available_budget: 0, enemy_template_builder: nil

  @typep t :: %__MODULE__{
    available_budget: integer(),
    enemy_template_builder: map()
  }

  @enemy_roles [:archer, :blocker, :caster, :leader, :spoiler, :troop, :wrecker]
  @enemy_levels [:same_level, :one_level_higher, :one_level_lower]
  @enemy_types [:standard, :double_strength, :triple_strength, :mook, :elite, :weakling]

  # def generate_enemies(complexity, difficulty, group_size)
  @spec generate_enemies(pos_integer()) :: {:ok, EnemyTemplate.t()} | {:error, term()}
  def generate_enemies(group_size)

  def generate_enemies(group_size)
    when group_size <= 0 or group_size > 7, do: {:error, :invalid_group_size}

  def generate_enemies(group_size) do
    available_enemy_budget = available_enemy_budget_for(group_size)

    enemy_template_builder =
      enemy_templates()
      |> Enum.filter(fn template -> template.min_budget_required <= available_enemy_budget end)
      |> Enum.random()

    generator_template = %__MODULE__{
      available_budget: available_enemy_budget - enemy_template_builder.min_budget_required,
      enemy_template_builder: enemy_template_builder
    }

    completed_template = complete_template(generator_template)

    {:ok, %EnemyTemplate{
      available_budget: available_enemy_budget,
      budget_used: available_enemy_budget - completed_template.available_budget,
      template: completed_template.enemy_template_builder.template
    }}
  end

  defp budget_used(template) do
    template.template
    |> Enum.map(fn enemy -> enemy_budget_cost_for(enemy) * enemy.amount end)
    |> Enum.sum()
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
          %{max_size: 2, enemy_types: [:wrecker]},
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

  defp complete_template(generator_template)
    when generator_template.available_budget <= 0.5, do: generator_template

  defp complete_template(generator_template) do
    generator_template
    |> maybe_add_new_enemy()
    |> maybe_increase_enemy_count()
  end

  defp maybe_add_new_enemy(generator_template) do
    add_new_enemy? =
      case length(generator_template.enemy_template_builder.template) do
        2 -> :rand.uniform(100) < 75
        3 -> :rand.uniform(100) < 50
        _ -> false
      end

    if add_new_enemy? do
      add_new_enemy(generator_template)
    else
      generator_template
    end
  end

  defp add_new_enemy(%__MODULE__{available_budget: available_budget, enemy_template_builder: template} = gen) do
    new_enemy = generate_enemy(template.addons)
    updated_template = %{template | template: [new_enemy | template.template]}

    if is_within_threshold(available_budget - enemy_budget_cost_for(new_enemy)) do
      %__MODULE__{
        available_budget: available_budget - enemy_budget_cost_for(new_enemy),
        enemy_template_builder: updated_template
      }
    else
      maybe_add_new_enemy(gen)
    end
  end

  defp maybe_increase_enemy_count(generator_template)
    when generator_template.available_budget <= 0.5, do: generator_template

  defp maybe_increase_enemy_count(%__MODULE__{available_budget: available_budget, enemy_template_builder: template} = gen) do
    bolstered_enemy =
      template.template
      |> Enum.random()
      |> Map.update!(:amount, &(&1+1))

    other_enemies =
      template.template
      |> Enum.filter(fn enemy -> not are_enemies_equal?(enemy, bolstered_enemy) end)

    updated_template = %{template | template: [bolstered_enemy | other_enemies]}

    if is_within_threshold(available_budget - enemy_budget_cost_for(bolstered_enemy)) do
      maybe_increase_enemy_count(%__MODULE__{
        available_budget: available_budget - enemy_budget_cost_for(bolstered_enemy),
        enemy_template_builder: updated_template
      })
    else
      maybe_increase_enemy_count(gen) # try, try again
    end
  end

  defp is_within_threshold(budget_remaining) do
    budget_remaining >= -0.5
  end

  defp are_enemies_equal?(enemy_a, enemy_b) do
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
