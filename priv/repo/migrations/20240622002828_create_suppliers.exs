defmodule Manager.Repo.Migrations.CreateSuppliers do
  use Ecto.Migration

  def change do
    create table(:suppliers) do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:suppliers, [:name])
  end
end
