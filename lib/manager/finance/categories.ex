defmodule Manager.Finance.Categories do
  import Ecto.Query
  alias Manager.Repo
  alias Manager.Finance.Category

  def list_categories do
    Repo.all(from c in Category, order_by: [asc: c.name])
  end

  def list_categories_by_type(type) do
    Repo.all(from c in Category, where: c.type in [^type, "both"], order_by: [asc: c.name])
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end
end
