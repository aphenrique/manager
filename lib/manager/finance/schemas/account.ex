defmodule Manager.Finance.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :name, :string
    field :type, :string, default: "checking"
    field :initial_balance, :decimal, default: Decimal.new(0)
    field :currency, :string, default: "BRL"
    field :color, :string, default: "#6366f1"
    field :icon, :string, default: "building-library"
    field :active, :boolean, default: true

    has_many :transactions, Manager.Finance.Transaction
    has_many :credit_cards, Manager.Finance.CreditCard

    timestamps(type: :utc_datetime)
  end

  @valid_types ~w(checking savings investment wallet)

  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :type, :initial_balance, :currency, :color, :icon, :active])
    |> validate_required([:name, :type, :initial_balance, :currency])
    |> validate_inclusion(:type, @valid_types)
    |> validate_length(:name, min: 1, max: 100)
    |> validate_number(:initial_balance, greater_than_or_equal_to: Decimal.new(0))
  end
end
