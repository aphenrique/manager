defmodule Manager.Transactions do
  import Ecto.Query, warn: false
  alias Manager.Repo

  alias Manager.Transactions.{Transaction, Category, Supplier}
  alias Manager.Accounts

  def list_transactions() do
    Repo.all(Transaction)
    |> Repo.preload([:category, :supplier, :account])
  end

  def list_transactions_by_user() do
    Repo.all(Transaction)
    |> Repo.preload([:category, :supplier, :account])
  end

  def get_transaction!(id) do
    Repo.get!(Transaction, id)
    |> Repo.preload([:category, :supplier, :account])
  end

  def create_transaction(attrs \\ %{}) do
    result =
      %Transaction{}
      |> Transaction.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, transaction} ->
        Accounts.update_balance(transaction)
    end
  end

  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
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
