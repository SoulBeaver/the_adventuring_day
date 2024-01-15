defmodule TheAdventuringDay.Repo.Migrations.CreateEnemyTemplateSpecs do
  use Ecto.Migration

  def change do
    create table(:enemy_template_specs) do
      add :min_budget_required, :float
      add :template, {:array, :map}
      add :addons, :map
      add :restrictions, {:array, :map}
      add :permutations, {:array, :map}
    end
  end

  def down do
    drop table(:enemy_template_specs)
  end
end
