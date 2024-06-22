defmodule Manager.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :name, :string, null: false
      add :supplier_id, references(:suppliers), null: false
      add :category_id, references(:categories), null: false
      add :account_id, references(:accounts), null: false
      add :type, :string, default: "out"
      add :value, :integer, default: 0, null: false
      add :realized, :boolean, default: false, null: false
      add :date, :date

      timestamps(type: :utc_datetime)
    end
  end
end
