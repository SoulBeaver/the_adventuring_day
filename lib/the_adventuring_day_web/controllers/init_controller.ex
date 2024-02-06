defmodule TheAdventuringDayWeb.InitController do
  use TheAdventuringDayWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias TheAdventuringDay.Infrastructure.Init.Init

  operation :init, false

  def init(conn, _params) do
    init_status = Init.seed_data()

    render(
        conn,
        :index,
        status: init_status
    )
  end
end
