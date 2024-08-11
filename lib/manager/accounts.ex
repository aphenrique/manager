defmodule Manager.Accounts do
  import Ecto.Query, warn: false
  alias Manager.Users.User
  alias Manager.Repo

  alias Manager.Accounts.Account

  def list_accounts() do
    Repo.all(Account)
    |> Repo.preload([:user])
  end

  def list_accounts_by_user(%User{} = user) do
    Repo.all(
      from a in Account,
        where: a.user_id == ^user.id,
        select: a
    )
  end

  def get_account!(id) do
    Repo.get!(Account, id)
    |> Repo.preload([:user])
  end

  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end
end
