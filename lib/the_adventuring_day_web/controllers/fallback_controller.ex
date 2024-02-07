defmodule TheAdventuringDayWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use TheAdventuringDayWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: TheAdventuringDayWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: TheAdventuringDayWeb.ErrorHTML, json: TheAdventuringDayWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, _reason}) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(html: TheAdventuringDayWeb.ErrorHTML, json: TheAdventuringDayWeb.ErrorJSON)
    |> render(:"500")
  end

  def call(conn, _) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(html: TheAdventuringDayWeb.ErrorHTML, json: TheAdventuringDayWeb.ErrorJSON)
    |> render(:"500")
  end
end
