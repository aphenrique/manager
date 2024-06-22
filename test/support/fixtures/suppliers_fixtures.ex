defmodule Manager.SuppliersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Manager.Suppliers` context.
  """

  @doc """
  Generate a supplier.
  """
  def supplier_fixture(attrs \\ %{}) do
    {:ok, supplier} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Manager.Suppliers.create_supplier()

    supplier
  end
end
