defmodule ManagerWeb.SupplierControllerTest do
  use ManagerWeb.ConnCase

  import Manager.SuppliersFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all suppliers", %{conn: conn} do
      conn = get(conn, ~p"/suppliers")
      assert html_response(conn, 200) =~ "Listing Suppliers"
    end
  end

  describe "new supplier" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/suppliers/new")
      assert html_response(conn, 200) =~ "New Supplier"
    end
  end

  describe "create supplier" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/suppliers", supplier: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/suppliers/#{id}"

      conn = get(conn, ~p"/suppliers/#{id}")
      assert html_response(conn, 200) =~ "Supplier #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/suppliers", supplier: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Supplier"
    end
  end

  describe "edit supplier" do
    setup [:create_supplier]

    test "renders form for editing chosen supplier", %{conn: conn, supplier: supplier} do
      conn = get(conn, ~p"/suppliers/#{supplier}/edit")
      assert html_response(conn, 200) =~ "Edit Supplier"
    end
  end

  describe "update supplier" do
    setup [:create_supplier]

    test "redirects when data is valid", %{conn: conn, supplier: supplier} do
      conn = put(conn, ~p"/suppliers/#{supplier}", supplier: @update_attrs)
      assert redirected_to(conn) == ~p"/suppliers/#{supplier}"

      conn = get(conn, ~p"/suppliers/#{supplier}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, supplier: supplier} do
      conn = put(conn, ~p"/suppliers/#{supplier}", supplier: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Supplier"
    end
  end

  describe "delete supplier" do
    setup [:create_supplier]

    test "deletes chosen supplier", %{conn: conn, supplier: supplier} do
      conn = delete(conn, ~p"/suppliers/#{supplier}")
      assert redirected_to(conn) == ~p"/suppliers"

      assert_error_sent 404, fn ->
        get(conn, ~p"/suppliers/#{supplier}")
      end
    end
  end

  defp create_supplier(_) do
    supplier = supplier_fixture()
    %{supplier: supplier}
  end
end
