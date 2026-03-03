defmodule Manager.Repo.Migrations.CreateCreditCardBills do
  use Ecto.Migration

  def change do
    create table(:credit_card_bills) do
      add :credit_card_id, references(:credit_cards, on_delete: :delete_all), null: false
      add :reference_month, :date, null: false
      add :closing_date, :date, null: false
      add :due_date, :date, null: false
      add :total_amount, :decimal, null: false, default: 0
      add :status, :string, null: false, default: "open"
      add :paid_at, :date

      timestamps(type: :utc_datetime)
    end

    create index(:credit_card_bills, [:credit_card_id])
    create index(:credit_card_bills, [:status])
    create unique_index(:credit_card_bills, [:credit_card_id, :reference_month])
  end
end
