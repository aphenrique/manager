defmodule Manager.Finance.Accounts do
  import Ecto.Query
  alias Manager.Repo
  alias Manager.Finance.{Account, Transaction}

  def list_accounts do
    Repo.all(from a in Account, where: a.active == true, order_by: [asc: a.name])
  end

  def list_all_accounts do
    Repo.all(from a in Account, order_by: [asc: a.name])
  end

  def get_account!(id), do: Repo.get!(Account, id)

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

  def current_balance(%Account{} = account) do
    income =
      Repo.one(
        from t in Transaction,
          where: t.account_id == ^account.id and t.type == "income",
          select: coalesce(sum(t.amount), 0)
      ) || Decimal.new(0)

    expense =
      Repo.one(
        from t in Transaction,
          where: t.account_id == ^account.id and t.type in ["expense", "transfer"],
          select: coalesce(sum(t.amount), 0)
      ) || Decimal.new(0)

    Decimal.add(account.initial_balance, Decimal.sub(income, expense))
  end

  def list_accounts_with_balance do
    accounts = list_accounts()
    Enum.map(accounts, fn account -> Map.put(account, :balance, current_balance(account)) end)
  end
end
