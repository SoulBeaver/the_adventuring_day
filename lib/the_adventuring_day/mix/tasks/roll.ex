defmodule Mix.Tasks.Roll do
  @moduledoc "The roll mix task: `mix roll npc`"

  use Mix.Task

  alias TheAdventuringDay.Component.RandomTable.Application.StoryWriter

  @requirements ["app.start"]

  @shortdoc "Outputs the result of the given stories."
  def run(args) do
    args
    |> Enum.map(&StoryWriter.write!/1)
    |> Enum.join("\n+--------+\n")
    |> IO.write()
  end
end
