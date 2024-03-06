defmodule TheAdventuringDay.Component.RandomTableParsing.Domain.Manifest do
  @moduledoc """
  A manifest file describing what the collection of random tables should be called (:collection_name)
  and the names of all sub-tables (:table_names).
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          collection_name: collection_name,
          table_names: list(table_name)
        }

  @type collection_name() :: String.t()
  @type table_name() :: String.t()

  @all_fields [:collection_name, :table_names]

  defstruct [:collection_name, table_names: []]

  @spec read(String.t()) :: {:ok, t()} | {:error, term()}
  def read(manifest_filename) do
    path = "." |> Path.expand() |> Path.join("data/unstructured_random_tables/#{manifest_filename}")

    with {:ok, file} <- File.read(path),
         {:ok, json} <- Jason.decode(file) do
      validate(json)
    end
  end

  defp validate(%{} = params) do
    data = %{}
    types = %{collection_name: :string, table_names: {:array, :string}}

    changeset =
      {data, types}
      |> cast(params, Map.keys(types))
      |> validate_required(@all_fields)

    case apply_action(changeset, :insert) do
      {:ok, data} -> {:ok, struct(__MODULE__, data)}
      {:error, _} = error -> error
    end
  end
end
