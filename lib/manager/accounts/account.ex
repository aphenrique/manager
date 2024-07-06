defmodule Manager.Accounts.Account do
  alias Manager.Users.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :name, :string
    field :type, :string, default: "current"
    field :balance, :integer
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :type, :balance, :user_id])
    |> validate_required([:name, :type])
  end
end
