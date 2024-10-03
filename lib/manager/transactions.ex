defmodule Manager.Transactions do
  import Ecto.Query, warn: false
  alias Manager.Repo

  alias Manager.Transactions.{Transaction, Category, Supplier}
  alias Manager.Accounts
  alias Manager.Accounts.Account
  alias Manager.Users.User

  def list_transactions() do
    Repo.all(Transaction)
    |> Repo.preload([:category, :supplier, :account])
  end

  def list_transactions_by_user(%User{} = user) do
    query =
      from t in Transaction,
        join: a in Account,
        on: t.account_id == a.id,
        where: a.user_id == ^user.id

    Repo.all(query)
    |> Repo.preload([:category, :supplier, :account])
  end

  def list_transactions_by_account_id(account_id) do
    query =
      from t in Transaction,
        join: a in Account,
        on: t.account_id == a.id,
        where: a.account_id == ^account_id

    Repo.all(query)
    |> Repo.preload([:category, :supplier, :account])
  end

  def get_transaction!(id) do
    Repo.get!(Transaction, id)
    |> Repo.preload([:category, :supplier, :account])
  end

  def create_transaction(attrs \\ %{}) do
    result =
      Accounts.get_account!(attrs["account_id"])
      |> Ecto.build_assoc(:transactions)
      |> Transaction.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, transaction} ->
        Accounts.update_balance(transaction)
    end

    result
  end

  def update_transaction(%Transaction{} = transaction, attrs) do
    new_value = attrs["value"] - transaction.value

    result =
      Accounts.get_account!(attrs["account_id"])
      |> Ecto.build_assoc(:transactions)
      |> Transaction.changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, transaction} ->
        Accounts.update_balance(transaction)
    end

    result

    # transaction
    # |> Transaction.changeset(attrs)
    # |> Repo.update()
  end

  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  #
  # Categories
  #
  def list_categories do
    Repo.all(Category)
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  #
  # Suppliers
  #
  def list_suppliers do
    Repo.all(Supplier)
  end

  def get_supplier!(id), do: Repo.get!(Supplier, id)

  def create_supplier(attrs \\ %{}) do
    %Supplier{}
    |> Supplier.changeset(attrs)
    |> Repo.insert()
  end

  def update_supplier(%Supplier{} = supplier, attrs) do
    supplier
    |> Supplier.changeset(attrs)
    |> Repo.update()
  end

  def delete_supplier(%Supplier{} = supplier) do
    Repo.delete(supplier)
  end

  def change_supplier(%Supplier{} = supplier, attrs \\ %{}) do
    Supplier.changeset(supplier, attrs)
  end
end
