# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TheAdventuringDay.Repo.insert!(%TheAdventuringDay.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TheAdventuringDay.Infrastructure.Init.Init

if Mix.env() == :dev or Mix.env() == :prod do
  Init.seed_data()
end
