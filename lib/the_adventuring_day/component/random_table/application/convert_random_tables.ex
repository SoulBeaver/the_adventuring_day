defmodule TheAdventuringDay.Component.RandomTable.Application.ConvertRandomTables do
  @moduledoc """
  TODO
  """

  alias TheAdventuringDay.Component.RandomTable.Domain.RandomTableCollection

  @type json() :: String.t()

  @repo Application.compile_env!(:the_adventuring_day, :random_table_collection_repo)

  @doc """
  TODO
  """
  @spec convert_random_tables([
          {:collection_name, String.t()}
          | {:table_names, list(String.t())}
          | {:random_table_data, json()}
        ]) :: RandomTableCollection.t()
  def convert_random_tables(collection_name: _coll_name, table_names: table_names, random_table_data: data)
    when length(table_names) != length(data) do
      {:error, :table_names_mismatch}
  end

  def convert_random_tables(
        collection_name: coll_name,
        table_names: table_names,
        random_table_data: data
      ) do
    converted_tables =
      Enum.zip(table_names, data)
      |> Map.new(fn {entry, name} -> convert_entry(entry, name) end)

    random_table_collection = RandomTableCollection.new(coll_name, converted_tables)

    case @repo.get(random_table_collection.collection_name) do
      nil ->
        @repo.create(random_table_collection)

      existing_collection ->
        %RandomTableCollection{random_table_collection | id: existing_collection.id}
        |> @repo.update()
    end
  end

  defp convert_entry(table_name, %{"results" => results}) do
    {table_name, results}
  end
end
