defmodule TheAdventuringDay.Repo.Migrations.CreateRandomTable do
  use Ecto.Migration

  def change do
    create table(:random_table_collections) do
      add :collection_name, :string
      add :tables, :map
    end
  end
end
