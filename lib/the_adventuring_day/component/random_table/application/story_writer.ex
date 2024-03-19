defmodule TheAdventuringDay.Component.RandomTable.Application.StoryWriter do
  @moduledoc """
  TODO
  """

  alias TheAdventuringDay.Component.RandomTable.Domain.StoryTemplate

  @random_table_repo Application.compile_env!(:the_adventuring_day, :random_table_collection_repo)

  def write(story_name) do
    with {:ok, story_file_path} <- file_path("#{story_name}.txt"),
         {:ok, story_template} <- read_story(story_file_path) do

      write_story(story_template)
    end
  end

  def write!(story_name) do
    with {:ok, story_file_path} <- file_path("#{story_name}.txt"),
         {:ok, story_template} <- read_story(story_file_path),
         {:ok, story} <- write_story(story_template) do

      story
    end
  end

  defp file_path(filename) do
    file_path =
      stories_path()
      |> Path.join("/#{filename}")

    if File.exists?(file_path) do
      {:ok, file_path}
    else
      {:error, :file_not_found}
    end
  end

  defp stories_path() do
    Application.get_env(:the_adventuring_day, :stories_path)
  end

  defp read_story(story_file_path) do
    story_template =
      story_file_path
      |> File.read!()
      |> StoryTemplate.new()

    {:ok, story_template}
  end

  defp write_story(%StoryTemplate{} = template) do
    with {:ok, random_table_collections} <- @random_table_repo.get_collections(template.fragments),
         {:ok, template_with_substitutions} <- StoryTemplate.with_substitutions(template, random_table_collections) do
      {:ok, StoryTemplate.write_story(template_with_substitutions)}
    else
      error -> error
    end
  end
end
