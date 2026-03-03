defmodule Manager.Finance.CreditCard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credit_cards" do
    field :name, :string
    field :limit, :decimal
    field :closing_day, :integer
    field :due_day, :integer
    field :color, :string, default: "#8b5cf6"
    field :active, :boolean, default: true

    belongs_to :account, Manager.Finance.Account
    has_many :bills, Manager.Finance.CreditCardBill
    has_many :transactions, Manager.Finance.Transaction

    timestamps(type: :utc_datetime)
  end

  def changeset(credit_card, attrs) do
    credit_card
    |> cast(attrs, [:name, :limit, :closing_day, :due_day, :color, :active, :account_id])
    |> validate_required([:name, :limit, :closing_day, :due_day])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_number(:limit, greater_than: Decimal.new(0))
    |> validate_number(:closing_day, greater_than_or_equal_to: 1, less_than_or_equal_to: 28)
    |> validate_number(:due_day, greater_than_or_equal_to: 1, less_than_or_equal_to: 31)
    |> foreign_key_constraint(:account_id)
  end
end
