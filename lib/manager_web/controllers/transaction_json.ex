defmodule ManagerWeb.TransactionJSON do
  alias Manager.Accounts.Account
  alias Manager.Transactions.{Transaction, Category, Supplier}

  def index(%{transactions: transactions}) do
    %{
      transactions: for(transaction <- transactions, do: show_transaction(transaction))
    }
  end

  def show_transaction(%Transaction{} = transaction) do
    %{
      name: transaction.name,
      type: transaction.type,
      value: transaction.value,
      date: transaction.date,
      supplier: show_supplier(transaction.supplier),
      category: show_category(transaction.category),
      account: show_account(transaction.account),
      realize: transaction.realized
    }
  end

  def show_supplier(%Supplier{} = supplier) do
    %{
      id: supplier.id,
      name: supplier.name
    }
  end

  def show_category(%Category{} = category) do
    %{
      id: category.id,
      name: category.name
    }
  end

  def show_account(%Account{} = account) do
    %{
      id: account.id,
      name: account.name
    }
  end
end
