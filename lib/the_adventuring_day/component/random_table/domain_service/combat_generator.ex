defmodule TheAdventuringDay.Component.RandomTable.DomainService.CombatGenerator do
  @moduledoc """
  TODO
  """

  alias TheAdventuringDay.Component.RandomTable.Domain.EnemyGenerator

  @type difficulty :: :easy | :medium | :hard | :deadly
  @type environment :: :indoor | :outdoor
  @type complexity :: :simple | :complex
  @type realism :: :grounded | :epic | :gonzo

  # def generate(complexity, realism, difficulty, environment, group_size)
  @spec generate(difficulty(), environment(), pos_integer()) :: map()
  def generate(difficulty, environment, group_size) do
    enemies = EnemyGenerator.generate_enemies(group_size)

    %{
      :enemies => enemies
    }
  end
end
