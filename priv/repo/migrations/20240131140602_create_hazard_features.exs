defmodule TheAdventuringDay.Repo.Migrations.CreateHazardFeatures do
  use Ecto.Migration

  def change do
    create table(:hazard_features) do
      add :hazard_type, :string
      add :name, :string
      add :description, :text
    end
  end

  def down do
    drop table(:hazard_features)
  end
end
