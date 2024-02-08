defmodule TheAdventuringDayWeb.AuthControllerTest do
  use TheAdventuringDayWeb.ConnCase, async: true

  test "test login link redirect to authdemo.fly.dev", %{conn: conn} do
    conn = get(conn, "/login")
    assert redirected_to(conn, 302) =~ "authdemo.fly.dev"
  end
end
