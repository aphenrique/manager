defmodule Manager.Accounts do
  import Ecto.Query, warn: false
  alias Manager.Users.User
  alias Manager.Repo

  alias Decimal

  alias Manager.Accounts.Account
  alias Manager.Transactions.Transaction

  def list_accounts() do
    Repo.all(Account)
    |> Repo.preload([:user])
  end

  def list_accounts_by_user(%User{} = user) do
    Repo.all(Ecto.assoc(user, :accounts))
  end

  def get_account!(id) do
    Repo.get!(Account, id)
    |> Repo.preload([:user])
  end

  def create_account(%User{} = user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:accounts)
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  def consolidate_balance(account_id) do
    transactions = Repo.all(from t in Transaction, where: t.account_id == ^account_id)

    total_balance =
      Enum.reduce(transactions, 0, fn transaction, acc ->
        value =
          case transaction.type do
            "out" -> -transaction.value
            _ -> transaction.value
          end

        acc + value
      end)

    case get_account!(account_id)
    |> update_account(%{balance: total_balance}) do
      {:ok, _} -> {:ok, total_balance}

      {:error, reason} -> {:error, reason}
    end
  end

  def update_balance(%Transaction{} = transaction) do
    value =
      case transaction.type do
        "out" -> -transaction.value
        _ -> transaction.value
      end

    account = get_account!(transaction.account_id)
    balance = account.balance + value

    case update_account(account, %{balance: balance}) do
      {:ok, updated_account} -> {:ok, updated_account}
      {:error, changeset} -> {:error, changeset.errors}
    end
  end

  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end
end
