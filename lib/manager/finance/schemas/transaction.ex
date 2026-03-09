defmodule Manager.Finance.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :description, :string
    field :amount, :decimal
    field :type, :string
    field :date, :date
    field :notes, :string
    field :incoming_transfer, :boolean, default: false

    belongs_to :account, Manager.Finance.Account
    belongs_to :credit_card, Manager.Finance.CreditCard
    belongs_to :credit_card_bill, Manager.Finance.CreditCardBill
    belongs_to :category, Manager.Finance.Category

    timestamps(type: :utc_datetime)
  end

  @valid_types ~w(income expense transfer)

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :description,
      :amount,
      :type,
      :date,
      :notes,
      :incoming_transfer,
      :account_id,
      :credit_card_id,
      :credit_card_bill_id,
      :category_id
    ])
    |> validate_required([:description, :amount, :type, :date])
    |> validate_inclusion(:type, @valid_types)
    |> validate_number(:amount, greater_than: Decimal.new(0))
    |> validate_length(:description, min: 1, max: 255)
    |> validate_account_or_card()
    |> foreign_key_constraint(:account_id)
    |> foreign_key_constraint(:credit_card_id)
    |> foreign_key_constraint(:credit_card_bill_id)
    |> foreign_key_constraint(:category_id)
  end

  defp validate_account_or_card(changeset) do
    account_id = get_field(changeset, :account_id)
    credit_card_id = get_field(changeset, :credit_card_id)

    if is_nil(account_id) and is_nil(credit_card_id) do
      add_error(changeset, :account_id, "deve pertencer a uma conta ou cartão de crédito")
    else
      changeset
    end
  end
end
