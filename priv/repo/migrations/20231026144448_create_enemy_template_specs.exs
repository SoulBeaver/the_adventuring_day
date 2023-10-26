defmodule TheAdventuringDay.Repo.Migrations.CreateEnemyTemplateSpecs do
  use Ecto.Migration

  def change do
    create table(:enemy_template_specs) do
      add :min_budget_required, :integer
      add :template, :map
      add :addons, :map
      add :restrictions, :map
      add :permutations, :map
    end
  end
end
