defmodule Manager.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :icon, :string

    timestamps(type: :utc_datetime)

  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :icon])
    |> validate_required([:name])
    |> validate_length(:name, min: 3)
  end
end
