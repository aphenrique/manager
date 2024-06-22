defmodule ManagerWeb.TransactionController do
  use ManagerWeb, :controller

  alias Manager.Transactions
  alias Manager.Transactions.Transaction

  def index(conn, _params) do
    transactions = Transactions.list_transactions()
    render(conn, :index, transactions: transactions)
  end

  def new(conn, _params) do
    changeset = Transactions.change_transaction(%Transaction{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"transaction" => transaction_params}) do
    case Transactions.create_transaction(transaction_params) do
      {:ok, transaction} ->
        conn
        |> put_flash(:info, "Transaction created successfully.")
        |> redirect(to: ~p"/transactions/#{transaction}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    transaction = Transactions.get_transaction!(id)
    render(conn, :show, transaction: transaction)
  end

  def edit(conn, %{"id" => id}) do
    transaction = Transactions.get_transaction!(id)
    changeset = Transactions.change_transaction(transaction)
    render(conn, :edit, transaction: transaction, changeset: changeset)
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = Transactions.get_transaction!(id)

    case Transactions.update_transaction(transaction, transaction_params) do
      {:ok, transaction} ->
        conn
        |> put_flash(:info, "Transaction updated successfully.")
        |> redirect(to: ~p"/transactions/#{transaction}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, transaction: transaction, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    transaction = Transactions.get_transaction!(id)
    {:ok, _transaction} = Transactions.delete_transaction(transaction)

    conn
    |> put_flash(:info, "Transaction deleted successfully.")
    |> redirect(to: ~p"/transactions")
  end
end
