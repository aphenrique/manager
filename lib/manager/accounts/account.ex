defmodule Manager.Accounts.Account do
  alias Manager.Users.User
  alias Manager.Transactions.Transaction

  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :name, :string
    field :type, :string, default: "current"
    field :balance, :integer
    belongs_to :user, User, type: :binary_id
    has_many :transactions, Transaction, foreign_key: :account_id, references: :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :type, :balance, :user_id])
    |> validate_required([:name, :type, :balance, :user_id])
  end
end
