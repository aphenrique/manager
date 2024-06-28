defmodule ManagerWeb.AccountJSON do
  alias Manager.Accounts.Account

  def index(%{accounts: accounts}) do
    %{
      accounts: for(account <- accounts, do: show_account(account))
    }
  end

  alias Manager.Accounts.Account

  defp show_account(%Account{} = account) do
    %{
      id: account.id,
      name: account.name
    }
  end
end
