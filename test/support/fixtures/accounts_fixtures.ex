defmodule Manager.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Manager.Accounts` context.
  """

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        balance: 42,
        name: "some name",
        type: "some type"
      })
      |> Manager.Accounts.create_account()

    account
  end
end
