defmodule TheAdventuringDayWeb.AuthController do
  use TheAdventuringDayWeb, :controller

  def login(conn, _params) do
    redirect(conn, external: AuthPlug.get_auth_url(conn, ~p"/"))
  end

  def logout(conn, _params) do
    conn
    |> AuthPlug.logout()
    |> put_status(302)
    |> redirect(to: ~p"/items")
  end
end
