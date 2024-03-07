defmodule TheAdventuringDay.Component.RandomTableParsing.DomainService.RandomTableParserTest do
  use ExUnit.Case

  alias TheAdventuringDay.Component.RandomTableParsing.DomainService.RandomTableParser
  alias TheAdventuringDay.Component.RandomTable.Domain.RandomTableCollection, as: Collection

  test "Parses a random table" do
    {:ok, collection} = RandomTableParser.parse("single_table_collection")

    assert Collection.exists?(collection, "mission_type")
    assert Collection.pick_random(collection, "mission_type") in ["Individual", "Item", "Location", "Event"]
  end

  test "Parses several random tables" do
    {:ok, collection} = RandomTableParser.parse("multiple_table_collection")

    ["mission_type", "individual_mission", "individual_subject_of_mission", "patrons_and_targets"]
    |> Enum.map(fn table_name ->
      assert Collection.exists?(collection, table_name)
    end)
  end
end
