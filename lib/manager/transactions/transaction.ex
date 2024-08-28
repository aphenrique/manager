defmodule Manager.Transactions.Transaction do
  alias Manager.Accounts.Account
  alias Manager.Transactions.{Category, Supplier}

  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :name,
    :type,
    :value,
    :date,
    :supplier_id,
    :category_id,
    :account_id,
    :realized
  ]

  schema "transactions" do
    field :name, :string
    field :type, :string, default: "out"
    field :value, :integer, default: 0
    field :date, :date
    belongs_to :supplier, Supplier
    belongs_to :category, Category
    belongs_to :account, Account, foreign_key: :account_id, references: :id
    field :realized, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :name,
      :type,
      :value,
      :date,
      :supplier_id,
      :category_id,
      :account_id,
      :realized
    ])
    |> validate_required(@fields)
  end
end
