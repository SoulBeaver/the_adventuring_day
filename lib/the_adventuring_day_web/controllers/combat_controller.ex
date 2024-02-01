defmodule TheAdventuringDayWeb.CombatController do
  use TheAdventuringDayWeb, :controller

  alias TheAdventuringDay.Component.Combat.DomainService.CombatGenerator

  def index(conn, _params) do
    with {:ok, combat_encounter} = CombatGenerator.generate(:medium, :outdoor, 4) do
      render(
        conn,
        :index,
        enemies: combat_encounter.enemies.template,
        terrain_features: combat_encounter.terrain_features,
        hazard_features: combat_encounter.hazard_features)
    end
  end
end
