defmodule ManagerWeb.AccountController do
  use ManagerWeb, :controller

  alias Manager.Accounts
  alias Manager.Accounts.Account

  def index(conn, _params) do
    user = conn.assigns.current_user

    accounts = Accounts.list_accounts_by_user(user)
    render(conn, :index, accounts: accounts)
  end

  def new(conn, _params) do
    changeset = Accounts.change_account(%Account{})

    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"account" => account_params}) do
    user = conn.assigns.current_user

    case Accounts.create_account(user, account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: ~p"/accounts/#{account}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    render(conn, :show, account: account)
  end

  def edit(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    changeset = Accounts.change_account(account)
    render(conn, :edit, account: account, changeset: changeset)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    case Accounts.update_account(account, account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: ~p"/accounts/#{account}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, account: account, changeset: changeset)
    end
  end


  def consolidate_account(conn, %{"id" => account_id}) do
    case Accounts.consolidate_balance(account_id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Conta consolidada com sucesso.")
        |> redirect(to: ~p"/accounts")

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    {:ok, _account} = Accounts.delete_account(account)

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: ~p"/accounts")
  end
end
