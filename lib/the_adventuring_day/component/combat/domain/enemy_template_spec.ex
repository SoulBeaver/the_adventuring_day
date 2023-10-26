defmodule TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpec do
  @moduledoc """
  TODO
  """

  use Ecto.Schema

  alias TheAdventuringDay.Component.Combat.Domain.EnemyGenerator.EnemyTemplate

  @type t() :: %__MODULE__{
    min_budget_required: pos_integer(),
    template: template(),
    addons: addons(),
    restrictions: restrictions(),
    permutations: permutations()
  }

  @type template :: list(EnemyTemplate.t())

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

  @type enemy_role :: EnemyTemplate.enemy_role()
  @type enemy_level :: EnemyTemplate.enemy_level()
  @type enemy_type :: EnemyTemplate.enemy_type()

  schema "enemy_template_specs" do
    field(:min_budget_required, :integer)
    field(:template, :map)
    field(:addons, :map)
    field(:restrictions, :map)
    field(:permutations, :map)
  end

  @spec new(pos_integer(), template(), addons(), restrictions(), permutations()) :: t()
  def new(min_budget_required, template, addons, restrictions, permutations) do
    %__MODULE__{
      min_budget_required: min_budget_required,
      template: template,
      addons: addons,
      restrictions: restrictions,
      permutations: permutations
    }
  end
end
