defmodule TheAdventuringDay.Repo.Migrations.CreateTerrainFeatures do
  use Ecto.Migration

  def change do
    create table(:terrain_features) do
      add :terrain_type, :string
      add :name, :string
      add :description, :text
      add :interior_examples, {:array, :string}
      add :exterior_examples, {:array, :string}
    end
  end

  def down do
    drop table(:terrain_features)
  end
end
