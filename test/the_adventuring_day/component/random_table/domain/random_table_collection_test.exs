defmodule TheAdventuringDay.Component.RandomTable.RandomTableCollectionTest do
  use ExUnit.Case, async: true

  alias TheAdventuringDay.Component.RandomTable.Domain.RandomTableCollection

  test "picks a random entry from list" do
    random_table = random_table_collection()

    assert RandomTableCollection.pick_random(random_table, "table") == "entry"
  end

  test "picks entry multiple times from list" do
    random_table = random_table_collection()

    assert RandomTableCollection.pick_random(random_table, "table", 3) == [
             "entry",
             "entry",
             "entry"
           ]
  end

  test "fails if 0 or less is given for pick_random" do
    random_table = random_table_collection()

    assert RandomTableCollection.pick_random(random_table, "table", 0) ==
             {:error, :illegal_number}

    assert RandomTableCollection.pick_random(random_table, "table", -1) ==
             {:error, :illegal_number}
  end

  test "fails if table doesn't exist" do
    random_table = random_table_collection()

    assert RandomTableCollection.pick_random(random_table, "missing") ==
              {:error, :unknown_table}
  end

  defp random_table_collection() do
    RandomTableCollection.new("ouat", %{"table" => ["entry"]})
  end
end
