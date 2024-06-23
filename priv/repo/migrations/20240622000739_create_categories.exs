defmodule Manager.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :icon, :string

      timestamps(type: :utc_datetime)
    end
  end
end
