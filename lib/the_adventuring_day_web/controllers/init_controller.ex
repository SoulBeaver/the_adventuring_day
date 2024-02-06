defmodule TheAdventuringDayWeb.InitController do
  use TheAdventuringDayWeb, :controller

  alias TheAdventuringDay.Infrastructure.Init.Init

  def index(conn, _params) do
    init_status = Init.seed_data()

    render(
        conn,
        :index,
        status: init_status
    )
  end
end
