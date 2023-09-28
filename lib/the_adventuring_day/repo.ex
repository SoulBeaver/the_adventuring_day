defmodule TheAdventuringDay.Repo do
  use Ecto.Repo,
    otp_app: :the_adventuring_day,
    adapter: Ecto.Adapters.Postgres
end
