defmodule TheAdventuringDay.Component.RandomTableParsing.DomainService.RandomTableParserTest do
  use ExUnit.Case

  alias TheAdventuringDay.Component.RandomTableParsing.DomainService.RandomTableParser
  alias TheAdventuringDay.Component.RandomTable.Domain.RandomTableCollection, as: Collection

  test "Parses a random table" do
    {:ok, collection} = RandomTableParser.parse("single_table_collection")

    assert Collection.exists?(collection, "mission_type")
  end
end
