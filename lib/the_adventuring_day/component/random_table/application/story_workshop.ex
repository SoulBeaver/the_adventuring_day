defmodule TheAdventuringDay.Component.RandomTable.Application.StoryWorkshop do
  @moduledoc """
  TODO
  """

  use GenServer

  alias TheAdventuringDay.Component.RandomTable.Domain.StoryTemplate

  @random_table_repo Application.compile_env!(:the_adventuring_day, :random_table_collection_repo)

  defstruct template: nil,
            written_story: nil

  @type written_story() :: String.t()

  @type t() :: %__MODULE__{
          template: StoryTemplate.t(),
          written_story: written_story()
        }

  def child_spec({id, story_text}) do
    %{
      id: {__MODULE__, id},
      start: {__MODULE__, :start_link, [{id, story_text}]},
      restart: :temporary
    }
  end

  def start_link({id, story_text}) do
    GenServer.start_link(
      __MODULE__,
      {id, story_text},
      name: via(id)
    )
  end

  def start_workshopping(id, story_text) do
    DynamicSupervisor.start_child(
      TheAdventuringDay.Supervisor.StoryWorkshop,
      {__MODULE__, {id, story_text}}
    )
  end

  def roll_dem_bones(id) do
    GenServer.call(via(id), :roll_dem_bones)
  end

  def reroll(id, fragments) when is_list(fragments) do
    GenServer.call(via(id), {:reroll, MapSet.new(fragments)})
  end

  def reroll(id) do
    GenServer.call(via(id), :reroll)
  end

  def finish(id) do
    GenServer.stop(via(id))
  end

  def init({id, story_text}) do
    {:ok, {id, %__MODULE__{template: StoryTemplate.new(story_text)}}}
  end

  def handle_call(:roll_dem_bones, _from, {id, %__MODULE__{} = workshop}) do
    case write_story_keep_substitutions(workshop) do
      {:ok, written_story, template_with_substitutions} ->
        {
          :reply,
          {written_story, template_with_substitutions.fragments},
          {id, %__MODULE__{workshop | template: template_with_substitutions, written_story: written_story}}
        }

      error ->
        error
    end
  end

  def handle_call(:reroll, _from, {id, %__MODULE__{} = workshop}) do
    fragments_keys =
      workshop.template.fragments
      |> MapSet.new(fn fragment -> fragment.fragment end)

    case reroll_story(workshop, fragments_keys) do
      {:ok, written_story, template_with_substitutions} ->
        {
          :reply,
          {written_story, template_with_substitutions.fragments},
          {id, %__MODULE__{workshop | template: template_with_substitutions, written_story: written_story}}
        }

      error ->
        {:reply, error, {id, workshop}}
    end
  end

  def handle_call({:reroll, fragments_keys}, _from, {id, %__MODULE__{} = workshop}) do
    case reroll_story(workshop, fragments_keys) do
      {:ok, written_story, template_with_substitutions} ->
        {
          :reply,
          {written_story, template_with_substitutions.fragments},
          {id, %__MODULE__{workshop | template: template_with_substitutions, written_story: written_story}}
        }

      error ->
        {:reply, error, {id, workshop}}
    end
  end

  defp reroll_story(workshop, fragments_keys) do
    with {:ok, updated_template} <- StoryTemplate.reset_fragments(workshop.template, fragments_keys) do
      updated_workshop = %__MODULE__{workshop | template: updated_template}

      write_story_keep_substitutions(updated_workshop)
    end
  end

  defp write_story_keep_substitutions(%__MODULE__{} = workshop) do
    with %StoryTemplate{} = template <- workshop.template,
         {:ok, random_table_collections} <- @random_table_repo.get_collections(template.fragments),
         {:ok, template_with_substitutions} <- StoryTemplate.with_substitutions(template, random_table_collections) do
      {:ok, StoryTemplate.write_story(template_with_substitutions), template_with_substitutions}
    else
      error -> error
    end
  end

  def via(id) do
    {
      :via,
      Registry,
      {TheAdventuringDay.Registry.StoryWorkshop, id}
    }
  end
end
