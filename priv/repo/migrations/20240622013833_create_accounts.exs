defmodule Manager.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string
      add :type, :string
      add :balance, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
