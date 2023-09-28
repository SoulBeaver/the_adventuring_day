defmodule TheAdventuringDay.Component.RandomTable.StoryFragmentTest do
  use ExUnit.Case

  alias TheAdventuringDay.Component.RandomTable.{RandomTableCollection, StoryFragment}

  test "creates a new fragment" do
    assert StoryFragment.new("coll.table") == %StoryFragment{
             fragment: "coll.table",
             collection_name: "coll",
             table_name: "table",
             substitution: nil
           }

    assert StoryFragment.new("coll_name.table_name") == %StoryFragment{
             fragment: "coll_name.table_name",
             collection_name: "coll_name",
             table_name: "table_name",
             substitution: nil
           }
  end

  test "adds a substitution" do
    coll = RandomTableCollection.new("coll", %{"name" => ["entry"]})

    fragment =
      StoryFragment.new("coll.name")
      |> StoryFragment.create_substitution(coll)

    assert fragment.substitution == "entry"
  end

  test "fails if the collection name is incorrect" do
    coll = RandomTableCollection.new("coll", %{"name" => ["entry"]})

    fragment =
      StoryFragment.new("missing.name")
      |> StoryFragment.create_substitution(coll)

    assert fragment ==
             {:error, :unable_to_substitute,
              %{
                expected_collection_name: "missing",
                actual_collection_name: "coll",
                expected_table_name: "name",
                actual_table_names: ["name"]
              }}
  end

  test "fails if the table name is incorrect" do
    coll = RandomTableCollection.new("coll", %{"name" => ["entry"]})

    fragment =
      StoryFragment.new("coll.missing")
      |> StoryFragment.create_substitution(coll)

    assert fragment ==
             {:error, :unable_to_substitute,
              %{
                expected_collection_name: "coll",
                actual_collection_name: "coll",
                expected_table_name: "missing",
                actual_table_names: ["name"]
              }}
  end
end
