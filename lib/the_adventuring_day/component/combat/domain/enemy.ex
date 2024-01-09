defmodule TheAdventuringDay.Component.Combat.Domain.Enemy do
  @moduledoc """
  TODO
  """

  use Ecto.Schema
  import Ecto.Changeset

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
    field :amount, :float
    field :role, Ecto.Enum, values: [:archer, :blocker, :caster, :leader, :skirmisher, :spoiler, :troop, :wrecker]
    field :level, Ecto.Enum, values: [:same_level, :one_level_higher, :one_level_lower]
    field :type, Ecto.Enum, values: [:standard, :double_strength, :triple_strength, :mook, :elite, :weakling]
  end

  def changeset(%__MODULE__{} = enemy, params \\ %{}) do
    enemy
    |> cast(params, [:amount, :role, :level, :type])
  end

  def budget_cost_for(%{amount: amount, role: _role, level: level, type: type}) do
    enemy_level_and_type_reference(level, type) * amount
  end

  def budget_cost_for_single(%{role: _role, level: level, type: type}) do
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
