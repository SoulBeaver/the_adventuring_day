defmodule TheAdventuringDay.Component.Combat.Domain.Permutation do
  @moduledoc """
  TODO
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias TheAdventuringDay.Component.Combat.Domain.Enemy
  alias TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpec

  @type t :: %{
          amount: pos_integer(),
          role: enemy_role(),
          level: enemy_level(),
          type: enemy_type()
        }

  @type enemy_role() :: EnemyTemplateSpec.enemy_role()
  @type enemy_level() :: EnemyTemplateSpec.enemy_level()
  @type enemy_type() :: EnemyTemplateSpec.enemy_type()

  embedded_schema do
    field :when_amount, :float
    field :when_role, Ecto.Enum, values: [:archer, :blocker, :caster, :leader, :skirmisher, :spoiler, :troop, :wrecker]
    field :when_level, Ecto.Enum, values: [:same_level, :one_level_higher, :one_level_lower]
    field :when_type, Ecto.Enum, values: [:standard, :double_strength, :triple_strength, :mook, :elite, :weakling]

    field :then_amount, :float
    field :then_role, Ecto.Enum, values: [:archer, :blocker, :caster, :leader, :skirmisher, :spoiler, :troop, :wrecker]
    field :then_level, Ecto.Enum, values: [:same_level, :one_level_higher, :one_level_lower]
    field :then_type, Ecto.Enum, values: [:standard, :double_strength, :triple_strength, :mook, :elite, :weakling]
  end

  def changeset(%__MODULE__{} = permutation, params \\ %{}) do
    permutation
    |> cast(params, [
      :when_amount,
      :when_role,
      :when_level,
      :when_type,
      :then_amount,
      :then_role,
      :then_level,
      :then_type
    ])
  end

  def matches?(%__MODULE__{} = permutation, %Enemy{} = enemy) do
    conditions =
      [
        {:amount, permutation.when_amount},
        {:role, permutation.when_role},
        {:level, permutation.when_level},
        {:type, permutation.when_type}
      ]
      |> Enum.filter(fn {_k, v} -> v != nil end)
      |> Enum.into(%{})

    conditions
    |> Map.intersect(enemy)
    |> Map.equal?(conditions)
  end

  def apply(%__MODULE__{} = permutation, %Enemy{} = enemy) do
    overrides =
      [
        {:amount, permutation.then_amount},
        {:role, permutation.then_role},
        {:level, permutation.then_level},
        {:type, permutation.then_type}
      ]
      |> Enum.filter(fn {_k, v} -> v != nil end)
      |> Enum.into(%{})

    Map.merge(enemy, overrides)
  end
end
