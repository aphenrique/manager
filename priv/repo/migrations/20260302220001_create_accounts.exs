defmodule Manager.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string, null: false
      add :type, :string, null: false, default: "checking"
      add :initial_balance, :decimal, null: false, default: 0
      add :currency, :string, null: false, default: "BRL"
      add :color, :string, null: false, default: "#6366f1"
      add :icon, :string, null: false, default: "building-library"
      add :active, :boolean, null: false, default: true

      timestamps(type: :utc_datetime)
    end

    create index(:accounts, [:active])
  end
end
