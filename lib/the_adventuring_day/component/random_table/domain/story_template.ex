defmodule TheAdventuringDay.Component.RandomTable.Domain.StoryTemplate do
  @moduledoc """
  TODO
  """

  alias TheAdventuringDay.Component.RandomTable.Domain.{RandomTableCollection, StoryFragment}

  @collection_regex ~r/#([a-zA-Z_.]+)#/

  defstruct ~w[story_template fragments]a

  @type t() :: %__MODULE__{
          story_template: story_template(),
          fragments: MapSet.t(StoryFragment.t())
        }
  @type story_template() :: String.t()
  @type written_story() :: String.t()

  @spec new(story_template) :: t()
  def new(story_template) do
    %__MODULE__{story_template: story_template, fragments: gather_fragments(story_template)}
  end

  defp gather_fragments(story_template) do
    @collection_regex
    |> Regex.scan(story_template)
    |> Enum.map(fn [_, match] -> match end)
    |> List.flatten()
    |> MapSet.new(&StoryFragment.new/1)
  end

  @spec with_substitutions(t(), %{RandomTableCollection.collection_name() => RandomTableCollection.t()}) :: {:ok, t()}
  def with_substitutions(%__MODULE__{} = story_template, collections) do
    case validate_collections(story_template.fragments, collections) do
      :ok ->
        fragments_with_substitutions =
          story_template.fragments
          |> MapSet.new(fn fragment ->
            StoryFragment.create_substitution(fragment, Map.get(collections, fragment.collection_name))
          end)

        {:ok, %__MODULE__{story_template | fragments: fragments_with_substitutions}}

      {:error, :missing_random_tables, _} = error ->
        error
    end
  end

  defp validate_collections(fragments, collections) do
    collection_names =
      collections
      |> Map.values()
      |> MapSet.new(fn collection -> collection.collection_name end)

    missing_collections =
      fragments
      |> Enum.reject(fn fragment ->
        fragment.collection_name in collection_names and
          RandomTableCollection.exists?(
            Map.get(collections, fragment.collection_name),
            fragment.table_name
          )
      end)
      |> Enum.map(fn fragment -> fragment.fragment end)

    case missing_collections do
      [] -> :ok
      missing_collections -> {:error, :missing_random_tables, missing_collections}
    end
  end

  @spec write_story(t()) :: written_story()
  def write_story(%__MODULE__{} = story_template) do
    story_template.fragments
    |> Enum.reduce(story_template.story_template, &replace_in_story/2)
  end

  defp replace_in_story(%StoryFragment{} = fragment, story_so_far) do
    story_so_far
    |> String.replace("##{fragment.fragment}#", fragment.substitution)
  end

  @spec reset_fragments(t(), %MapSet{}) :: {:ok, t()} | {:error, :unexpected_fragments_keys, %MapSet{}}
  def reset_fragments(%__MODULE__{} = template, fragments_keys) do
    case validate_fragments(template.fragments, fragments_keys) do
      {:ok, fragments_to_reset} ->
        remaining_fragments =
          template.fragments
          |> MapSet.reject(fn fragment -> fragment.fragment in fragments_keys end)

        {:ok, %__MODULE__{template | fragments: MapSet.union(remaining_fragments, fragments_to_reset)}}

      error ->
        error
    end
  end

  defp validate_fragments(fragments, fragments_keys) do
    unexpected_fragments =
      fragments_keys
      |> MapSet.difference(MapSet.new(fragments, fn fragment -> fragment.fragment end))

    case MapSet.size(unexpected_fragments) do
      0 ->
        {:ok, fragments_keys |> MapSet.new(&StoryFragment.new/1)}

      _ ->
        {:error, :unexpected_fragments_keys, unexpected_fragments}
    end
  end
end
