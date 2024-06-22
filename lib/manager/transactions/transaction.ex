defmodule Manager.Transactions.Transaction do
  alias Manager.Accounts.Account
  alias Manager.Categories.Category
  alias Manager.Suppliers.Supplier

  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :name, :string
    field :type, :string, default: "out"
    field :value, :integer, default: 0
    field :date, :date
    belongs_to :supplier, Supplier
    belongs_to :category, Category
    belongs_to :account, Account
    field :realized, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:name, :supplier_id, :category_id, :type, :value, :realized, :date])
    |> validate_required([:name, :supplier_id, :category_id, :type, :value, :realized, :date])
  end
end
