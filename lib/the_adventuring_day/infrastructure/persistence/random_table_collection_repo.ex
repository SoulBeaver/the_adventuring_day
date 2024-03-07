defmodule TheAdventuringDay.Infrastructure.Persistence.RandomTableCollectionRepo do
  alias TheAdventuringDay.Repo
  alias TheAdventuringDay.Component.RandomTable.Domain.{RandomTableCollection, StoryFragment}

  import Ecto.{Query, Changeset}, warn: false

  @valid_fields [:collection_name, :tables]

  @spec create(RandomTableCollection.t()) :: RandomTableCollection.t()
  def create(%RandomTableCollection{} = random_table_collection) do
    random_table_collection
    |> dehydrate_table_results()
    |> cast(%{}, @valid_fields)
    |> Repo.insert()
  end

  @spec update(RandomTableCollection.t()) :: RandomTableCollection.t()
  def update(%RandomTableCollection{} = random_table_collection) do
    values = Map.take(random_table_collection, @valid_fields)

    %RandomTableCollection{id: random_table_collection.id}
    |> dehydrate_table_results()
    |> cast(values, @valid_fields)
    |> Repo.update()
  end

  @spec get_collections(list(StoryFragment.t())) ::
          {:ok, %{RandomTableCollection.collection_name() => RandomTableCollection.t()}}
  def get_collections(fragments) do
    collection_names =
      fragments
      |> Enum.map(fn fragment -> fragment.collection_name end)
      |> MapSet.new()

    collections =
      collection_names
      |> Enum.map(&get/1)
      |> Map.new(fn collection -> {collection.collection_name, collection} end)

    {:ok, collections}
  end

  @spec get(String.t()) :: RandomTableCollection.t() | nil
  def get(collection_name) do
    Repo.get_by(RandomTableCollection, collection_name: collection_name)
    |> hydrate_table_results()
  end

  def truncate() do
    Repo.query("TRUNCATE random_table_collections")
  end

  defp dehydrate_table_results(%RandomTableCollection{tables: tables} = collection) do
    updated_tables =
      tables
      |> Enum.map(fn {table_name, results} ->
        {table_name, results |> Enum.map(&Tuple.to_list/1)}
      end)
      |> Enum.into(%{})

    %RandomTableCollection{collection | tables: updated_tables}
  end

  defp hydrate_table_results(%RandomTableCollection{tables: tables} = collection) do
    updated_tables =
      tables
      |> Enum.map(fn {table_name, results} ->
        hydrated_results =
          results
          |> Enum.map(fn [result_type, result] ->
            {String.to_atom(result_type), result}
          end)

        {table_name, hydrated_results}
      end)
      |> Enum.into(%{})

    %RandomTableCollection{collection | tables: updated_tables}
  end
end
