defmodule TheAdventuringDay.Repo.Migrations.CreateCombatEncounter do
  use Ecto.Migration

  def change do
    create table(:combat_encounter) do
      add :person_id, :integer

      add :enemies, :map
      add :terrain_features, {:array, :map}
      add :hazards, {:array, :map}

      timestamps()
    end
  end
end
