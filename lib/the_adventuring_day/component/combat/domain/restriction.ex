defmodule TheAdventuringDay.Component.Combat.Domain.Restriction do
  @moduledoc """
  TODO
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpec

  @type restriction :: %{
    max_size: pos_integer(),
    enemy_roles: list(enemy_role())
  }

  @type enemy_role() :: EnemyTemplateSpec.enemy_role()

  embedded_schema do
    field :max_size, :integer
    field :enemy_roles, {:array, Ecto.Enum}, values: [:archer, :blocker, :caster, :leader, :skirmisher, :spoiler, :troop, :wrecker]
  end

  def changeset(restrictions, params \\ %{}) do
    restrictions
    |> cast(params, [:max_size, :enemy_roles])
  end
end
