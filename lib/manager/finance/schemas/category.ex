defmodule Manager.Finance.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :color, :string, default: "#6366f1"
    field :icon, :string, default: "tag"
    field :type, :string, default: "expense"

    has_many :transactions, Manager.Finance.Transaction

    timestamps(type: :utc_datetime)
  end

  @valid_types ~w(income expense both)

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :color, :icon, :type])
    |> validate_required([:name, :type])
    |> validate_inclusion(:type, @valid_types)
    |> validate_length(:name, min: 1, max: 100)
    |> unique_constraint(:name)
  end
end
