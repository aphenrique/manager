defmodule Manager.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :description, :string, null: false
      add :amount, :decimal, null: false
      add :type, :string, null: false
      add :date, :date, null: false
      add :notes, :text
      add :account_id, references(:accounts, on_delete: :restrict)
      add :credit_card_id, references(:credit_cards, on_delete: :restrict)
      add :credit_card_bill_id, references(:credit_card_bills, on_delete: :restrict)
      add :category_id, references(:categories, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:account_id])
    create index(:transactions, [:credit_card_id])
    create index(:transactions, [:credit_card_bill_id])
    create index(:transactions, [:category_id])
    create index(:transactions, [:date])
    create index(:transactions, [:type])
  end
end
