defmodule TheAdventuringDay.Infrastructure.Persistence.EnemyTemplateSpecRepo do
  @moduledoc """
  TODO
  """

  import Ecto.Query

  alias TheAdventuringDay.Component.Combat.Domain.EnemyTemplateSpec
  alias TheAdventuringDay.Repo

  @spec insert_enemy_template_spec(map()) :: {:ok, EnemyTemplateSpec.t()} | {:error, term()}
  def insert_enemy_template_spec(params) do
    %EnemyTemplateSpec{}
    |> EnemyTemplateSpec.changeset(params)
    |> Repo.insert()
  end

  @spec insert_enemy_template_spec!(map()) :: EnemyTemplateSpec.t()
  def insert_enemy_template_spec!(params) do
    %EnemyTemplateSpec{}
    |> EnemyTemplateSpec.changeset(params)
    |> Repo.insert!()
  end

  @spec random_enemy_template_spec(pos_integer()) :: EnemyTemplateSpec.t()
  def random_enemy_template_spec(available_budget) do
    query =
      from(ets in EnemyTemplateSpec,
        where: ets.min_budget_required <= ^available_budget,
        order_by: fragment("RANDOM()"),
        limit: 1
      )

    Repo.one!(query)
  end

  def truncate() do
    Repo.query("TRUNCATE enemy_template_specs")
  end
end
