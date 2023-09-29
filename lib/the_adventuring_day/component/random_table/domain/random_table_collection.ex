defmodule TheAdventuringDay.Component.RandomTable.Domain.RandomTableCollection do
  @moduledoc """
  TODO
  """

  use Ecto.Schema

  @type random_table_entry :: String.t()
  @type collection_name() :: String.t()
  @type table_name() :: String.t()
  @type tables() :: %{table_name() => list(random_table_entry())}

  @type t() :: %__MODULE__{
          collection_name: String.t(),
          tables: tables()
        }

  schema "random_table_collections" do
    field(:collection_name, :string)
    field(:tables, :map)
  end

  @spec new(collection_name(), tables()) :: t()
  def new(collection_name, tables) do
    %__MODULE__{collection_name: collection_name, tables: tables}
  end

  @spec collection_name(t()) :: collection_name
  def collection_name(collection), do: collection.collection_name

  @spec tables(t()) :: tables()
  def tables(collection), do: collection.tables

  @spec exists?(t(), table_name()) :: boolean()
  def exists?(collection, table_name) do
    collection.tables
    |> Map.has_key?(table_name)
  end

  @spec pick_random(t(), table_name()) :: random_table_entry()
  def pick_random(collection, table_name) do
    case collection.tables[table_name] do
      nil -> {:error, :unknown_table}
      table -> Enum.random(table)
    end
  end

  @spec pick_random(t(), table_name(), pos_integer()) :: list(random_table_entry())
  def pick_random(collection, table_name, times) when times > 0 do
    for _ <- 1..times, do: pick_random(collection, table_name)
  end

  def pick_random(_coll, _table_name, _times), do: {:error, :illegal_number}
end
