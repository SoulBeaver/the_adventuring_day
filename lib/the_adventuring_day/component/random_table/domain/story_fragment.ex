defmodule TheAdventuringDay.Component.RandomTable.Domain.StoryFragment do
  @moduledoc """
  TODO
  """

  alias TheAdventuringDay.Component.RandomTable.Domain.RandomTableCollection

  defstruct ~w[fragment collection_name table_name substitution]a

  @type t() :: %__MODULE__{
          fragment: String.t(),
          collection_name: String.t(),
          table_name: String.t(),
          substitution: String.t() | nil
        }

  @spec new(String.t()) :: t()
  def new(fragment) do
    [collection_name, table_name] =
      fragment
      |> String.split(".")

    %__MODULE__{
      fragment: fragment,
      collection_name: collection_name,
      table_name: table_name,
      substitution: nil
    }
  end

  def table_name(%__MODULE__{} = fragment), do: fragment.table_name

  def collection_name(%__MODULE__{} = fragment), do: fragment.collection_name

  @defaults %{reroll_all: false}

  @spec create_substitution(t(), RandomTableCollection.t(), list()) :: t()
  def create_substitution(%__MODULE__{} = fragment, collection, options \\ []) do
    %{reroll_all: reroll_all} = Enum.into(options, @defaults)

    substitute_fragment(fragment, collection, reroll_all: reroll_all)
  end

  defp substitute_fragment(%__MODULE__{substitution: nil} = fragment, collection, _reroll) do
    with true <- collection.collection_name == fragment.collection_name,
         true <- Map.has_key?(collection.tables, fragment.table_name) do
      %__MODULE__{
        fragment | substitution: RandomTableCollection.pick_random(collection, fragment.table_name)
      }
    else
      _ ->
        {:error, :unable_to_substitute,
         %{
           expected_collection_name: fragment.collection_name,
           actual_collection_name: collection.collection_name,
           expected_table_name: fragment.table_name,
           actual_table_names: collection.tables |> Map.keys()
         }}
    end
  end

  defp substitute_fragment(fragment, collection, reroll_all: true) do
    substitute_fragment(%__MODULE__{fragment | substitution: nil}, collection, true)
  end

  defp substitute_fragment(fragment, _collection, _reroll),
    do: fragment
end
