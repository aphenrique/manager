defmodule ManagerWeb.SupplierController do
  use ManagerWeb, :controller

  alias Manager.Transactions
  alias Manager.Transactions.Supplier

  def index(conn, _params) do
    suppliers = Transactions.list_suppliers()
    render(conn, :index, suppliers: suppliers)
  end

  def new(conn, _params) do
    changeset = Transactions.change_supplier(%Supplier{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"supplier" => supplier_params}) do
    case Transactions.create_supplier(supplier_params) do
      {:ok, supplier} ->
        conn
        |> put_flash(:info, "Supplier created successfully.")
        |> redirect(to: ~p"/suppliers/#{supplier}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    supplier = Transactions.get_supplier!(id)
    render(conn, :show, supplier: supplier)
  end

  def edit(conn, %{"id" => id}) do
    supplier = Transactions.get_supplier!(id)
    changeset = Transactions.change_supplier(supplier)
    render(conn, :edit, supplier: supplier, changeset: changeset)
  end

  def update(conn, %{"id" => id, "supplier" => supplier_params}) do
    supplier = Transactions.get_supplier!(id)

    case Transactions.update_supplier(supplier, supplier_params) do
      {:ok, supplier} ->
        conn
        |> put_flash(:info, "Supplier updated successfully.")
        |> redirect(to: ~p"/suppliers/#{supplier}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, supplier: supplier, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    supplier = Transactions.get_supplier!(id)
    {:ok, _supplier} = Transactions.delete_supplier(supplier)

    conn
    |> put_flash(:info, "Supplier deleted successfully.")
    |> redirect(to: ~p"/suppliers")
  end
end
