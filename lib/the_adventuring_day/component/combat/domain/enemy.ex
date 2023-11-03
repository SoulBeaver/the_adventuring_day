defmodule TheAdventuringDay.Component.Combat.Domain.Enemy do
  @moduledoc """
  TODO
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %{
    amount: pos_integer(),
    role: enemy_role(),
    level: enemy_level(),
    type: enemy_type()
  }

  @type enemy_role() :: :archer | :blocker | :caster | :leader | :spoiler | :troop | :wrecker
  @type enemy_level() :: :same_level | :one_level_higher | :one_level_lower | :two_levels_higher | :two_levels_lower
  @type enemy_type() :: :standard | :double_strength | :triple_strength | :mook | :elite | :weakling

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
end
