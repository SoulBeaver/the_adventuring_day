defmodule TheAdventuringDayWeb.InitController do
  use TheAdventuringDayWeb, :controller

  alias TheAdventuringDay.Infrastructure.Init.Init

  def index(conn, _params) do
    init = Init.seed_data()

    render(
        conn,
        :index,
        init: init
    )
  end
end
