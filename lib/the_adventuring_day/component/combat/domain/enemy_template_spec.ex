defmodule TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpec do
  @moduledoc """
  TODO
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias TheAdventuringDay.Component.Combat.Domain.Enemy

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

  @enemy_roles [:archer, :blocker, :caster, :leader, :spoiler, :troop, :wrecker]
  @enemy_levels [:same_level, :one_level_higher, :one_level_lower]
  @enemy_types [:standard, :double_strength, :triple_strength, :mook, :elite, :weakling]

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

    embeds_many :restrictions, Restrictions do
      field :max_size, :integer
      field :enemy_roles, {:array, Ecto.Enum}, values: [:archer, :blocker, :caster, :leader, :skirmisher, :spoiler, :troop, :wrecker]
    end

    embeds_many :permutations, Permutations do
      field :when, :map
      field :then, :map
    end
  end

  def changeset(%__MODULE__{} = spec, params \\ %{}) do
    spec
    |> cast(params, @all_fields)
    |> cast_embed(:template)
    |> cast_embed(:addons, with: &addons_changeset/2)
    |> cast_embed(:restrictions, with: &restrictions_changeset/2)
    |> cast_embed(:permutations, with: &permutations_changeset/2)
    |> validate_number(:min_budget_required, greater_than: 0)
  end

  def addons_changeset(addons, params \\ %{}) do
    addons
    |> cast(params, [:enemy_roles, :enemy_levels, :enemy_types])
  end

  def restrictions_changeset(restrictions, params \\ %{}) do
    restrictions
    |> cast(params, [:max_size, :enemy_roles])
  end

  def permutations_changeset(permutations, params \\ %{}) do
    permutations
    |> cast(params, [:when, :then])
  end

  def generate_enemy(%__MODULE__{addons: addons}) do
    role = addons.enemy_roles |> Enum.random()
    enemy_level = addons.enemy_levels |> Enum.random()
    enemy_type =
      if :rand.uniform(100) > 90 do
        addons.enemy_types |> Enum.random()
      else
        :standard
      end

    %Enemy{amount: 1, role: role, level: enemy_level, type: enemy_type}
  end
end
