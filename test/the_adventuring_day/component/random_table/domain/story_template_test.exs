defmodule TheAdventuringDay.Component.RandomTable.Domain.StoryTemplateTest do
  use ExUnit.Case

  alias TheAdventuringDay.Component.RandomTable.Domain.{StoryFragment, StoryTemplate}

  test "loading a story template" do
    story_template =
      StoryTemplate.new("Once upon a time there was a #ouat.damsel# in #ouat.situation#.")

    assert story_template.fragments ==
             MapSet.new([
               StoryFragment.new("ouat.damsel"),
               StoryFragment.new("ouat.situation")
             ])
  end

  test "story template captures fragments with underscores (_)" do
    story_template = StoryTemplate.new("#ouat.damsel_in_distress#.")

    assert story_template.fragments == MapSet.new([StoryFragment.new("ouat.damsel_in_distress")])
  end

  test "story template avoids duplicates" do
    story_template = StoryTemplate.new("#ouat.damsel#, #ouat.situation#, #ouat.damsel#.")

    assert story_template.fragments ==
             MapSet.new([
               StoryFragment.new("ouat.damsel"),
               StoryFragment.new("ouat.situation")
             ])
  end

  test "story template works with complex stories" do
    story_template =
      """
      Once upon a time there was a #ouat.damsel# who was kidnapped by a #ouat.adjective# #ouat.monster#.
      
      When soon there came a #ouat.hero# #ouat.hero_attire# who #ouat.monster_interaction# the #ouat.monster# and #ouat.rescuee_interaction# the #ouat.damsel#.
      
      The end.
      """
      |> StoryTemplate.new()

    assert story_template.fragments ==
             MapSet.new([
               StoryFragment.new("ouat.damsel"),
               StoryFragment.new("ouat.adjective"),
               StoryFragment.new("ouat.monster"),
               StoryFragment.new("ouat.hero"),
               StoryFragment.new("ouat.hero_attire"),
               StoryFragment.new("ouat.monster_interaction"),
               StoryFragment.new("ouat.rescuee_interaction")
             ])
  end
end
