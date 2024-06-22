defmodule Manager.CategoriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Manager.Categories` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        icon: "some icon",
        name: "some name"
      })
      |> Manager.Categories.create_category()

    category
  end
end
