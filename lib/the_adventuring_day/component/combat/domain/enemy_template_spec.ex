defmodule TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpec do
  @moduledoc """
  TODO
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias TheAdventuringDay.Component.Combat.Domain.Enemy
  alias TheAdventuringDay.Component.Combat.Domain.Restriction
  alias TheAdventuringDay.Component.Combat.Domain.Permutation

  @type t() :: %__MODULE__{
    min_budget_required: pos_integer(),
    template: template(),
    addons: addons(),
    restrictions: restrictions(),
    permutations: permutations()
  }

  @type template :: list(enemy())

  @type enemy :: %{
    amount: pos_integer(),
    role: enemy_role(),
    level: enemy_level(),
    type: enemy_type()
  }

  @type addons :: %{
    enemy_roles: list(enemy_role()),
    enemy_levels: list(enemy_level()),
    enemy_types: list(enemy_type())
  }

  @type restrictions :: list(restriction())

  @type restriction :: %{
    max_size: pos_integer(),
    enemy_roles: list(enemy_role())
  }

  @type permutations :: list(permutation())

  @type permutation :: %{
    when: map(),
    then: map()
  }

  @type enemy_role() :: :archer | :blocker | :caster | :leader | :spoiler | :troop | :wrecker
  @type enemy_level() :: :same_level | :one_level_higher | :one_level_lower | :two_levels_higher | :two_levels_lower
  @type enemy_type() :: :standard | :double_strength | :triple_strength | :mook | :elite | :weakling

  @all_fields [
    :min_budget_required
  ]

  schema "enemy_template_specs" do
    field :min_budget_required, :float

    embeds_many :template, Enemy

    embeds_one :addons, Addons do
      field :enemy_roles, {:array, Ecto.Enum}, values: [:archer, :blocker, :caster, :leader, :skirmisher, :spoiler, :troop, :wrecker]
      field :enemy_levels, {:array, Ecto.Enum}, values: [:same_level, :one_level_higher, :one_level_lower]
      field :enemy_types, {:array, Ecto.Enum}, values: [:standard, :double_strength, :triple_strength, :mook, :elite, :weakling]
    end

    embeds_many :restrictions, Restriction
    embeds_many :permutations, Permutation
  end

  @spec changeset(TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpec.t()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = spec, params \\ %{}) do
    spec
    |> cast(params, @all_fields)
    |> cast_embed(:template)
    |> cast_embed(:addons, with: &addons_changeset/2)
    |> cast_embed(:restrictions)
    |> cast_embed(:permutations)
    |> validate_number(:min_budget_required, greater_than: 0)
  end

  defp addons_changeset(addons, params) do
    addons
    |> cast(params, [:enemy_roles, :enemy_levels, :enemy_types])
  end

  @doc """
  Calculates the total budget required for this template
  """
  @spec budget_cost(t()) :: pos_integer()
  def budget_cost(%__MODULE__{template: template}) do
    template
    |> Enum.map(fn enemy -> Enemy.budget_cost_for(enemy) end)
    |> Enum.sum()
  end

  @doc """
  Generates a new enemy based on the Addons section of the template
  """
  @spec generate_enemy(t()) :: Enemy.t()
  def generate_enemy(%__MODULE__{addons: addons} = enemy_template_spec) do
    role = addons.enemy_roles |> Enum.random()
    enemy_level = addons.enemy_levels |> Enum.random()
    enemy_type = generate_pseudorandom_enemy_type(enemy_template_spec)

    %Enemy{amount: 1, role: role, level: enemy_level, type: enemy_type}
  end

  defp generate_pseudorandom_enemy_type(enemy_template_spec) do
    any_mooks_present? =
      enemy_template_spec.template
      |> Enum.any?(fn enemy -> enemy.type == :mook end)

    # Prefer the generation of a new mook enemy if none exist.
    if any_mooks_present? do
      if :rand.uniform(100) > 90 do
        enemy_template_spec.addons.enemy_types |> Enum.random()
      else
        :standard
      end
    else
      if :rand.uniform(100) > 10 do
        :mook
      else
        :standard
      end
    end
  end

  @doc """
  Applies any matching permutations to the existing template.

  For example, if a step during the enemy_generator adds a second wrecker unit to the template
  and the permutations looked like so:

    permutations: [
      %{when_amount: 2, when_role: :wrecker, then_type: :standard}
    ]

  Then this step would change the type of the two wreckers to :standard.
  """
  @spec apply_permutations(t()) :: t()
  def apply_permutations(%__MODULE__{permutations: permutations} = enemy_template_spec) do
    updated_template =
      enemy_template_spec.template
      |> Enum.map(fn enemy -> apply_permutation(permutations, enemy) end)

    %{enemy_template_spec | template: updated_template}
  end

  defp apply_permutation(permutations, enemy) do
    applicable_permutation =
      permutations
      |> Enum.find(fn permutation -> Permutation.matches?(permutation, enemy) end)

    if applicable_permutation != nil do
      Permutation.apply(applicable_permutation, enemy)
    else
      enemy
    end
  end

  @doc """
  Returns a list of enemies this template is able to generate based on the
  template's Restrictions.

  A common example is to have only one :leader unit per template so as to not
  overcomplicate combat or create HP sponges due to their healing effects.
  """
  @spec filter_restricted(t()) :: template()
  def filter_restricted(enemy_template_spec)

  def filter_restricted(%__MODULE__{} = enemy_template_spec) when length(enemy_template_spec.restrictions) == 0 do
    enemy_template_spec.template
  end

  def filter_restricted(%__MODULE__{} = enemy_template_spec) do
    restrictions = enemy_template_spec.restrictions

    enemy_template_spec.template
    |> Enum.filter(fn enemy ->
      restrictions |> Enum.all?(fn %{max_size: max_size, enemy_roles: enemy_roles} ->
        (enemy.role not in enemy_roles) or (enemy.amount < max_size)
      end)
    end)
  end
end
