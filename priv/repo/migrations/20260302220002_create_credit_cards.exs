defmodule Manager.Repo.Migrations.CreateCreditCards do
  use Ecto.Migration

  def change do
    create table(:credit_cards) do
      add :name, :string, null: false
      add :limit, :decimal, null: false
      add :closing_day, :integer, null: false
      add :due_day, :integer, null: false
      add :color, :string, null: false, default: "#8b5cf6"
      add :active, :boolean, null: false, default: true
      add :account_id, references(:accounts, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:credit_cards, [:account_id])
    create index(:credit_cards, [:active])
  end
end
