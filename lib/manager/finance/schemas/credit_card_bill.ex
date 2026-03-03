defmodule Manager.Finance.CreditCardBill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credit_card_bills" do
    field :reference_month, :date
    field :closing_date, :date
    field :due_date, :date
    field :total_amount, :decimal, default: Decimal.new(0)
    field :status, :string, default: "open"
    field :paid_at, :date

    belongs_to :credit_card, Manager.Finance.CreditCard
    has_many :transactions, Manager.Finance.Transaction

    timestamps(type: :utc_datetime)
  end

  @valid_statuses ~w(open closed paid)

  def changeset(bill, attrs) do
    bill
    |> cast(attrs, [
      :credit_card_id,
      :reference_month,
      :closing_date,
      :due_date,
      :total_amount,
      :status,
      :paid_at
    ])
    |> validate_required([:credit_card_id, :reference_month, :closing_date, :due_date])
    |> validate_inclusion(:status, @valid_statuses)
    |> foreign_key_constraint(:credit_card_id)
    |> unique_constraint([:credit_card_id, :reference_month])
  end
end
