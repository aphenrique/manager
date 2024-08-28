defmodule ManagerWeb.CategoryController do
  use ManagerWeb, :controller

  alias Manager.Transactions
  alias Manager.Transactions.Category

  def index(conn, _params) do
    categories = Transactions.list_categories()
    render(conn, :index, categories: categories)
  end

  def new(conn, _params) do
    changeset = Transactions.change_category(%Category{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"category" => category_params}) do
    case Transactions.create_category(category_params) do
      {:ok} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: ~p"/categories")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Transactions.get_category!(id)
    render(conn, :show, category: category)
  end

  def edit(conn, %{"id" => id}) do
    category = Transactions.get_category!(id)
    changeset = Transactions.change_category(category)
    render(conn, :edit, category: category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Transactions.get_category!(id)

    case Transactions.update_category(category, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: ~p"/categories/#{category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, category: category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Transactions.get_category!(id)
    {:ok, _category} = Transactions.delete_category(category)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: ~p"/categories")
  end
end
