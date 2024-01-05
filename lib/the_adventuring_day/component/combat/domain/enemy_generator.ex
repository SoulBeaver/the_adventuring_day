defmodule TheAdventuringDay.Component.Combat.Domain.EnemyGenerator do
  @moduledoc """
  TODO rename monster to enemy
  """

  alias TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpec

  defmodule GeneratedEnemyTemplate do
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

    @type enemy_role() :: EnemyTemplateSpec.enemy_role()
    @type enemy_level() :: EnemyTemplateSpec.enemy_level()
    @type enemy_type() :: EnemyTemplateSpec.enemy_type()
  end

  defstruct available_budget: 0, enemy_template_spec: nil

  # def generate_enemies(complexity, difficulty, group_size)
  @spec generate_enemies(pos_integer()) :: {:ok, GeneratedEnemyTemplate.t()} | {:error, term()}
  def generate_enemies(group_size)

  def generate_enemies(group_size)
    when group_size <= 0 or group_size > 7, do: {:error, :invalid_group_size}

  def generate_enemies(group_size) do
    available_budget = available_encounter_budget_for(group_size)
    enemy_template_spec = random_enemy_template_builder_spec(available_budget)

    generator_template = %__MODULE__{
      available_budget: available_budget - enemy_template_spec.min_budget_required,
      enemy_template_spec: enemy_template_spec
    }

    completed_template = complete_template(generator_template)

    {:ok, %GeneratedEnemyTemplate{
      available_budget: available_budget,
      budget_used: available_budget - completed_template.available_budget,
      template: completed_template.enemy_template_spec.template |> sanitize_template()
    }}
  end

  defp random_enemy_template_builder_spec(available_budget) do
    repo = Application.get_env(:the_adventuring_day, :enemy_template_spec_repo)

    repo.random_enemy_template_spec(available_budget)
  end

  defp available_encounter_budget_for(4), do: 5
  defp available_encounter_budget_for(5), do: 7
  defp available_encounter_budget_for(6), do: 9
  defp available_encounter_budget_for(7), do: 11
  defp available_encounter_budget_for(group_size) when group_size < 4, do: group_size

  defp complete_template(generator_template)
    when generator_template.available_budget <= 0.5, do: generator_template

  defp complete_template(generator_template) do
    generator_template
    |> maybe_add_new_enemy()
    |> maybe_increase_enemy_count()
    |> apply_permutations()
    |> complete_template()
  end

  defp maybe_add_new_enemy(generator_template) do
    must_add_new_enemy? =
      capable_of_adding_to_existing_enemies?(generator_template)

    maybe_add_new_enemy? =
      case length(generator_template.enemy_template_spec.template) do
        2 -> :rand.uniform(100) < 75
        3 -> :rand.uniform(100) < 50
        _ -> false
      end

    if must_add_new_enemy? or maybe_add_new_enemy? do
      add_new_enemy(generator_template)
    else
      generator_template
    end
  end

  defp capable_of_adding_to_existing_enemies?(%__MODULE__{available_budget: available_budget, enemy_template_spec: template_spec} = gen) do
    not(template_spec.template
    |> filter_restricted(template_spec)
    |> Enum.filter(fn enemy ->
      is_within_threshold?(available_budget - enemy_budget_cost_for(enemy |> Map.update!(:amount, &(&1+1))))
    end)
    |> Enum.empty?())
  end

  defp add_new_enemy(%__MODULE__{available_budget: available_budget, enemy_template_spec: template} = gen) do
    new_enemy = EnemyTemplateSpec.generate_enemy(template)
    updated_template = %{template | template: [new_enemy | template.template]}

    if is_within_threshold?(available_budget - enemy_budget_cost_for(new_enemy)) do
      %__MODULE__{
        available_budget: available_budget - enemy_budget_cost_for(new_enemy),
        enemy_template_spec: updated_template
      }
    else
      maybe_add_new_enemy(gen)
    end
  end

  defp maybe_increase_enemy_count(generator_template)
    when generator_template.available_budget <= 0.5, do: generator_template

  defp maybe_increase_enemy_count(%__MODULE__{available_budget: available_budget, enemy_template_spec: template} = gen) do
    bolstered_enemy =
      template.template
      |> filter_restricted(template)
      |> Enum.random()
      |> Map.update!(:amount, &(&1+1))

    other_enemies =
      template.template
      |> Enum.filter(fn enemy -> not are_enemies_equal?(enemy, bolstered_enemy) end)

    updated_template = %{template | template: [bolstered_enemy | other_enemies]}

    is_within_threshold? = is_within_threshold?(available_budget - enemy_budget_cost_for(bolstered_enemy))

    if is_within_threshold? do
      %__MODULE__{
        available_budget: available_budget - enemy_budget_cost_for(bolstered_enemy),
        enemy_template_spec: updated_template
      }
    else
      gen
    end
  end

  defp filter_restricted(enemy_template, template_spec) when length(template_spec.restrictions) == 0 do
    enemy_template
  end

  defp filter_restricted(enemy_template, template_spec) do
    restrictions = template_spec.restrictions

    enemy_template
    |> Enum.filter(fn enemy ->
      restrictions |> Enum.any?(fn %{max_size: max_size, enemy_roles: enemy_roles} ->
        (enemy.role not in enemy_roles) or (enemy.amount < max_size)
      end)
    end)
  end

  defp is_within_threshold?(budget_remaining) do
    budget_remaining >= -0.5
  end

  defp are_enemies_equal?(enemy_a, enemy_b) do
    enemy_a.role == enemy_b.role &&
    enemy_a.level == enemy_b.level &&
    enemy_a.type == enemy_b.type
  end

  defp sanitize_template(template) do
    template
    |> Enum.map(fn t -> Map.from_struct(t) |> Map.delete(:id) end)
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

  defp apply_permutations(%__MODULE__{enemy_template_spec: template_spec} = gen) when length(template_spec.permutations) == 0 do
    gen
  end

  defp apply_permutations(%__MODULE__{enemy_template_spec: template_spec} = gen) do
    permutations = template_spec.permutations

    updated_template =
      template_spec.template
      |> Enum.map(fn enemy -> apply_permutation(permutations, enemy) end)

    %{gen | enemy_template_spec: %{template_spec | template: updated_template}}
    #|> IO.inspect(label: :updated_template_spec)
  end

  defp apply_permutation(permutations, enemy) do
    enemy
    # |> IO.inspect(label: :enemy)

    permutation? =
      permutations
      |> Enum.find(fn %{when: when_clause} ->
        IO.inspect(enemy, label: :enemy)
        IO.inspect(when_clause, label: :when_clause)

        Map.intersect(enemy, when_clause)
        |> Map.equal?(when_clause)
      end)

    if permutation? != nil do
      permutation? |> IO.inspect(label: :permutation)
      enemy |> IO.inspect(label: :enemy_to_update)

      Map.merge(enemy, permutation?.then)
      |> IO.inspect(label: :updated_enemy)
    else
      enemy
    end
  end
end
