defmodule Manager.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Manager.Transactions` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        category_id: 42,
        date: ~D[2024-06-21],
        name: "some name",
        realized: true,
        supplier_id: 42,
        type: "some type",
        value: 42
      })
      |> Manager.Transactions.create_transaction()

    transaction
  end
end
