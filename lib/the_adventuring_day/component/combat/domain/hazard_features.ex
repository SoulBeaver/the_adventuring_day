defmodule TheAdventuringDay.Component.Combat.Domain.HazardFeatures do
  @moduledoc """
  TODO
  """

use Ecto.Schema
import Ecto.Changeset

@type t() :: %__MODULE__{
  hazard_type: hazard_type(),
  name: String.t(),
  description: String.t()
}

@type hazard_type :: :trap | :terrain | :zone

@all_fields [:hazard_type, :name, :description]
@hazard_types [:trap, :terrain, :zone]

schema "hazard_features" do
  field :hazard_type, Ecto.Enum, values: [:trap, :terrain, :zone]
  field :name, :string
  field :description, :string
end

def changeset(%__MODULE__{} = spec, params \\ %{}) do
  spec
  |> cast(params, @all_fields)
  |> validate_required(@all_fields)
  |> validate_inclusion(:hazard_type, @hazard_types)
end
end
