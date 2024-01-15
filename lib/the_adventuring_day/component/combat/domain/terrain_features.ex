defmodule TheAdventuringDay.Component.Combat.Domain.TerrainFeatures do
  @moduledoc """
  TODO
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
    terrain_type: terrain_type(),
    name: String.t(),
    description: String.t(),
    interior_examples: list(String.t()),
    exterior_examples: list(String.t())
  }

  @type terrain_type :: :difficult | :hindering | :blocking | :challenging | :obscured | :cover

  @all_fields [:terrain_type, :name, :description, :interior_examples, :exterior_examples]
  @terrain_types [:difficult, :hindering, :blocking, :challenging, :obscured, :cover]

  schema "terrain_features" do
    field :terrain_type, Ecto.Enum, values: [:difficult, :hindering, :blocking, :challenging, :obscured, :cover]
    field :name, :string
    field :description, :string
    field :interior_examples, {:array, :string}
    field :exterior_examples, {:array, :string}
  end

  def changeset(%__MODULE__{} = spec, params \\ %{}) do
    spec
    |> cast(params, @all_fields)
    |> validate_required(@all_fields)
    |> validate_inclusion(:terrain_type, @terrain_types)
  end
end
