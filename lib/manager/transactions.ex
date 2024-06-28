defmodule Manager.Transactions do
  import Ecto.Query, warn: false
  alias Manager.Repo

  alias Manager.Transactions.Transaction

  def list_transactions do
    Repo.all(Transaction)
    |> Repo.preload([:category, :supplier, :account])
  end

  def get_transaction!(id) do
    Repo.get!(Transaction, id)
    |> Repo.preload([:category, :supplier, :account])
  end

  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
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
end
