defmodule TheAdventuringDay.Infrastructure.Persistence.CombatEncounterRepo do
  @moduledoc """
  TODO
  """

  import Ecto.Query

  alias TheAdventuringDay.Component.Combat.Domain.CombatEncounter
  alias TheAdventuringDay.Repo

  @type combat_encounter_id :: integer()
  @type person_id :: integer()

  # @spec insert_combat_encounter(map()) :: {:ok, CombatEncounter.t()} | {:error, term()}
  def insert_combat_encounter(params) do
    %CombatEncounter{}
    |> CombatEncounter.changeset(params)
    |> Repo.insert()
  end

  # @spec insert_combat_encounter!(map()) :: CombatEncounter.t()
  def insert_combat_encounter!(params) do
    %CombatEncounter{}
    |> CombatEncounter.changeset(params)
    |> Repo.insert!()
  end

  # @spec combat_encounter(combat_encounter_id(), person_id()) :: CombatEncounter.t()
  def get_combat_encounter!(combat_encounter_id, person_id) do
    from(
      ce in CombatEncounter,
      where: ce.person_id == ^person_id and ce.id == ^combat_encounter_id
    )
    |> Repo.one!()
  end

  def truncate() do
    Repo.query("TRUNCATE combat_encounter")
  end
end
