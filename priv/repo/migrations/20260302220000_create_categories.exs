defmodule Manager.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :color, :string, null: false, default: "#6366f1"
      add :icon, :string, null: false, default: "tag"
      add :type, :string, null: false, default: "expense"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:categories, [:name])
    create index(:categories, [:type])
  end
end
