defmodule TheAdventuringDay.Component.Combat.Domain.CombatEncounter do
  @moduledoc """
  TODO
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "combat_encounter" do
    field :person_id, :integer

    embeds_one :enemies, CombatEncounterEnemies do
      field :available_budget, :float
      field :budget_used, :float

      embeds_many :template, CombatEncounterEnemiesTemplate do
        field :amount, :integer
        field :role, Ecto.Enum, values: [:archer, :blocker, :caster, :leader, :skirmisher, :spoiler, :troop, :wrecker]
        field :level, Ecto.Enum, values: [:same_level, :one_level_higher, :one_level_lower]
        field :type, Ecto.Enum, values: [:standard, :double_strength, :triple_strength, :mook, :elite, :weakling]
      end
    end

    embeds_many :terrain_features, CombatEncounterTerrainFeatures do
      field :terrain_type, Ecto.Enum, values: [:difficult, :hindering, :blocking, :challenging, :obscured, :cover]
      field :name, :string
      field :description, :string
      field :interior_examples, {:array, :string}
      field :exterior_examples, {:array, :string}
    end

    embeds_many :hazards, CombatEncounterHazards do
      field :hazard_type, Ecto.Enum, values: [:trap, :terrain, :zone]
      field :name, :string
      field :description, :string
    end

    timestamps()
  end

  # @spec changeset(TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpec.t()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = spec, params \\ %{}) do
    spec
    |> cast(params, [:person_id])
    |> cast_embed(:enemies, with: &enemies_changeset/2)
    |> cast_embed(:terrain_features, with: &terrain_features_changeset/2)
    |> cast_embed(:hazards, with: &hazards_changeset/2)
  end

  defp enemies_changeset(enemy_template, params) do
    all_fields = [:available_budget, :budget_used]

    enemy_template
    |> cast(params, all_fields)
    |> cast_embed(:template, with: &enemy_template_template_changeset/2)
    |> validate_required(all_fields)
  end

  defp enemy_template_template_changeset(template, params) do
    all_fields = [:amount, :role, :level, :type]

    template
    |> cast(params, all_fields)
    |> validate_required(all_fields)
  end

  defp terrain_features_changeset(terrain_features, params) do
    all_fields = [:terrain_type, :name, :description, :interior_examples, :exterior_examples]

    terrain_features
    |> cast(params, all_fields)
    |> validate_required(all_fields)
  end

  defp hazards_changeset(hazards, params) do
    all_fields = [:hazard_type, :name, :description]

    hazards
    |> cast(params, all_fields)
    |> validate_required(all_fields)
  end
end
