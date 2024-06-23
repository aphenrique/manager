defmodule Manager.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string, null: false
      add :type, :string, null: false, default: "corrente"
      add :balance, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end
  end
end
