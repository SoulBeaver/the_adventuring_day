defmodule TheAdventuringDay.Component.Combat.DomainService.EnemyGenerator do
  @moduledoc """
  TODO rename monster to enemy
  """

  alias TheAdventuringDay.Component.Combat.Domain.Enemy
  alias TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpec

  # How far over budget the generation is allowed to go.
  @budget_threshold -0.5

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

  defstruct total_budget: 0, available_budget: 0, enemy_template_spec: nil

  @doc """
  Generates a list of enemies for the encounter based on an existing template.
  A template looks something like this:

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
    }

  It is pre-populated with a selection of enemies. Each enemy has:

  - Amount. How many units of that kind.
  - Role. The role of the unit specific to the 13th Age ruleset.
  - Level. Its level relative to the party.
  - Type. Its strength as a unit. Standard units are roughly on par with 1 PC, double_strength 2 PCs and so on.

  Generation adds to the existing enemies or creates new ones based on the available budget given by the group_size parameter.
  There's a little wiggle room, but generation stops once the template is within -0.5 - 0.5 of the available budget.

  New enemies are added from the available list of the Addons section. The maximum amount and type of enemies is limited by
  the Restrictions section. Permutations changes the existing template based on certain parameters. In the above example two
  :double_strength wreckers are downgraded to :standard even if they fit into the budget because of the massive damage they'd cause.
  """
  @spec generate_enemies(pos_integer()) :: {:ok, GeneratedEnemyTemplate.t()} | {:error, term()}
  def generate_enemies(group_size)

  def generate_enemies(group_size)
      when group_size <= 0 or group_size > 7,
      do: {:error, :invalid_group_size}

  def generate_enemies(group_size) do
    available_budget = available_encounter_budget_for(group_size)
    enemy_template_spec = random_enemy_template_builder_spec(available_budget)

    generator_template = %__MODULE__{
      total_budget: available_budget,
      available_budget: available_budget - enemy_template_spec.min_budget_required,
      enemy_template_spec: enemy_template_spec
    }

    completed_template = complete_template(generator_template)

    {:ok,
     %GeneratedEnemyTemplate{
       available_budget: available_budget,
       budget_used: available_budget - completed_template.available_budget,
       template: completed_template.enemy_template_spec.template |> sanitize_template()
     }}
  end

  defp random_enemy_template_builder_spec(available_budget) do
    repo = Application.get_env(:the_adventuring_day, :enemy_template_spec_repo)

    repo.random_enemy_template_spec!(available_budget)
  end

  defp available_encounter_budget_for(4), do: 5
  defp available_encounter_budget_for(5), do: 7
  defp available_encounter_budget_for(6), do: 9
  defp available_encounter_budget_for(7), do: 11
  defp available_encounter_budget_for(group_size) when group_size < 4, do: group_size

  defp complete_template(generator_template)
       when generator_template.available_budget <= 0.5,
       do: generator_template

  defp complete_template(generator_template) do
    generator_template
    |> maybe_add_new_enemy()
    |> maybe_increase_enemy_count()
    |> apply_permutations()
    |> complete_template()
  end

  defp maybe_add_new_enemy(generator_template) do
    must_add_new_enemy? =
      not capable_of_adding_to_existing_enemies?(generator_template)

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

  defp capable_of_adding_to_existing_enemies?(%__MODULE__{
         available_budget: available_budget,
         enemy_template_spec: template_spec
       }) do
    not (EnemyTemplateSpec.filter_restricted(template_spec)
         |> Enum.filter(fn enemy ->
           is_within_budget_threshold?(available_budget - Enemy.budget_cost_for_single(enemy))
         end)
         |> Enum.empty?())
  end

  defp add_new_enemy(%__MODULE__{available_budget: available_budget, enemy_template_spec: template} = gen) do
    new_enemy = EnemyTemplateSpec.generate_enemy(template)
    updated_template = %{template | template: [new_enemy | template.template]}

    if is_within_budget_threshold?(available_budget - Enemy.budget_cost_for_single(new_enemy)) do
      %__MODULE__{
        total_budget: gen.total_budget,
        available_budget: available_budget - Enemy.budget_cost_for_single(new_enemy),
        enemy_template_spec: updated_template
      }
    else
      maybe_add_new_enemy(gen)
    end
  end

  defp maybe_increase_enemy_count(generator_template)
       when generator_template.available_budget <= 0.5,
       do: generator_template

  defp maybe_increase_enemy_count(
         %__MODULE__{available_budget: available_budget, enemy_template_spec: enemy_template_spec} = gen
       ) do
    bolstered_enemy =
      EnemyTemplateSpec.filter_restricted(enemy_template_spec)
      |> Enum.filter(fn enemy ->
        is_within_budget_threshold?(available_budget - Enemy.budget_cost_for_single(enemy))
      end)
      |> Enum.random()
      |> Map.update!(:amount, &(&1 + 1))

    other_enemies =
      enemy_template_spec.template
      |> Enum.filter(fn enemy -> not are_enemies_equal?(enemy, bolstered_enemy) end)

    updated_enemy_template_spec = %{enemy_template_spec | template: [bolstered_enemy | other_enemies]}

    is_within_budget_threshold? =
      is_within_budget_threshold?(gen.total_budget - EnemyTemplateSpec.budget_cost(updated_enemy_template_spec))

    if is_within_budget_threshold? do
      %__MODULE__{
        total_budget: gen.total_budget,
        available_budget: gen.total_budget - EnemyTemplateSpec.budget_cost(updated_enemy_template_spec),
        enemy_template_spec: updated_enemy_template_spec
      }
    else
      gen
    end
  end

  defp is_within_budget_threshold?(budget_remaining) do
    budget_remaining >= @budget_threshold
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

  defp apply_permutations(%__MODULE__{enemy_template_spec: template_spec} = gen)
       when length(template_spec.permutations) == 0 do
    gen
  end

  defp apply_permutations(%__MODULE__{total_budget: total_budget, enemy_template_spec: template_spec} = gen) do
    updated_template = EnemyTemplateSpec.apply_permutations(template_spec)
    updated_budget = total_budget - EnemyTemplateSpec.budget_cost(template_spec)

    %{gen | available_budget: updated_budget, enemy_template_spec: updated_template}
  end
end
