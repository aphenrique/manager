defmodule Manager.Repo.Migrations.CreateSuppliers do
  use Ecto.Migration

  def change do
    create table(:suppliers) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
