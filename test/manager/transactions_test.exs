defmodule Manager.TransactionsTest do
  use Manager.DataCase

  alias Manager.Transactions

  describe "transactions" do
    alias Manager.Transactions.Transaction

    import Manager.TransactionsFixtures

    @invalid_attrs %{name: nil, type: nil, value: nil, date: nil, supplier_id: nil, category_id: nil, realized: nil}

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Transactions.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Transactions.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      valid_attrs = %{name: "some name", type: "some type", value: 42, date: ~D[2024-06-21], supplier_id: 42, category_id: 42, realized: true}

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert transaction.name == "some name"
      assert transaction.type == "some type"
      assert transaction.value == 42
      assert transaction.date == ~D[2024-06-21]
      assert transaction.supplier_id == 42
      assert transaction.category_id == 42
      assert transaction.realized == true
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      update_attrs = %{name: "some updated name", type: "some updated type", value: 43, date: ~D[2024-06-22], supplier_id: 43, category_id: 43, realized: false}

      assert {:ok, %Transaction{} = transaction} = Transactions.update_transaction(transaction, update_attrs)
      assert transaction.name == "some updated name"
      assert transaction.type == "some updated type"
      assert transaction.value == 43
      assert transaction.date == ~D[2024-06-22]
      assert transaction.supplier_id == 43
      assert transaction.category_id == 43
      assert transaction.realized == false
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Transactions.update_transaction(transaction, @invalid_attrs)
      assert transaction == Transactions.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Transactions.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Transactions.change_transaction(transaction)
    end
  end
end
