defmodule TheAdventuringDay.Component.RandomTable.Application.StoryWorkshopTest do
  use TheAdventuringDay.DataCase

  alias TheAdventuringDay.Component.RandomTable.Domain.{RandomTableCollection, StoryFragment}
  alias TheAdventuringDay.Component.RandomTable.Application.StoryWorkshop

  @repo Application.compile_env!(:the_adventuring_day, :random_table_collection_repo)

  setup do
    @repo.truncate()
    :ok
  end

  test "workshopping a story" do
    {:ok, collection} =
      RandomTableCollection.new("locations_all", %{"description" => ["Nebulous"], "structure" => ["Spire"]})
      |> @repo.create()

    story = "The #locations_all.description# #locations_all.structure#"

    {:ok, _pid} = StoryWorkshop.start_workshopping("location", story)
    {story, fragments} = StoryWorkshop.roll_dem_bones("location")

    assert story == "The Nebulous Spire"

    assert fragments ==
             MapSet.new([
               StoryFragment.new("locations_all.description")
               |> StoryFragment.create_substitution(collection),
               StoryFragment.new("locations_all.structure")
               |> StoryFragment.create_substitution(collection)
             ])
  end

  test "with replacements" do
    {:ok, collection} =
      RandomTableCollection.new("locations_all", %{"description" => ["Nebulous"], "structure" => ["Spire"]})
      |> @repo.create()

    story = "The #locations_all.description# #locations_all.structure#"

    {:ok, _pid} = StoryWorkshop.start_workshopping("replacement", story)
    _ = StoryWorkshop.roll_dem_bones("replacement")

    @repo.truncate()

    {:ok, alt_collection} =
      RandomTableCollection.new("locations_all", %{"description" => ["Bright"], "structure" => ["Quarry"]})
      |> @repo.create()

    {story, fragments} = StoryWorkshop.reroll("replacement", ["locations_all.description"])

    assert story == "The Bright Spire"

    assert fragments ==
             MapSet.new([
               StoryFragment.new("locations_all.description")
               |> StoryFragment.create_substitution(alt_collection),
               StoryFragment.new("locations_all.structure")
               |> StoryFragment.create_substitution(collection)
             ])
  end
end
