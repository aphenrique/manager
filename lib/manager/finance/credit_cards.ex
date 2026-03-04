defmodule Manager.Finance.CreditCards do
  import Ecto.Query
  alias Manager.Repo
  alias Manager.Finance.{CreditCard, CreditCardBill, Transaction}

  def list_credit_cards do
    Repo.all(
      from c in CreditCard,
        where: c.active == true,
        preload: [:account],
        order_by: [asc: c.name]
    )
  end

  def get_credit_card!(id) do
    Repo.get!(CreditCard, id) |> Repo.preload(:account)
  end

  def create_credit_card(attrs \\ %{}) do
    %CreditCard{}
    |> CreditCard.changeset(attrs)
    |> Repo.insert()
  end

  def update_credit_card(%CreditCard{} = credit_card, attrs) do
    credit_card
    |> CreditCard.changeset(attrs)
    |> Repo.update()
  end

  def delete_credit_card(%CreditCard{} = credit_card) do
    Repo.delete(credit_card)
  end

  def change_credit_card(%CreditCard{} = credit_card, attrs \\ %{}) do
    CreditCard.changeset(credit_card, attrs)
  end

  def get_or_create_open_bill(%CreditCard{} = card) do
    today = Date.utc_today()
    reference_month = current_reference_month(card, today)

    case Repo.get_by(CreditCardBill, credit_card_id: card.id, reference_month: reference_month) do
      nil -> create_open_bill(card, reference_month, today)
      bill -> {:ok, bill}
    end
  end

  def current_bill(%CreditCard{} = card) do
    today = Date.utc_today()
    reference_month = current_reference_month(card, today)

    Repo.get_by(CreditCardBill, credit_card_id: card.id, reference_month: reference_month)
  end

  def list_bills(%CreditCard{} = card) do
    Repo.all(
      from b in CreditCardBill,
        where: b.credit_card_id == ^card.id,
        order_by: [desc: b.reference_month]
    )
  end

  def close_bill(%CreditCardBill{} = bill) do
    total =
      Repo.one(
        from t in Transaction,
          where: t.credit_card_bill_id == ^bill.id,
          select: coalesce(sum(t.amount), 0)
      ) |> to_decimal()

    bill
    |> CreditCardBill.changeset(%{status: "closed", total_amount: total})
    |> Repo.update()
  end

  def pay_bill(%CreditCardBill{} = bill, payment_account_id) do
    today = Date.utc_today()

    Repo.transaction(fn ->
      {:ok, updated_bill} =
        bill
        |> CreditCardBill.changeset(%{status: "paid", paid_at: today})
        |> Repo.update()

      {:ok, _transaction} =
        %Transaction{}
        |> Transaction.changeset(%{
          description: "Pagamento fatura #{bill.credit_card_id}",
          amount: bill.total_amount,
          type: "expense",
          date: today,
          account_id: payment_account_id
        })
        |> Repo.insert()

      updated_bill
    end)
  end

  def current_balance(%CreditCard{} = card) do
    case get_or_create_open_bill(card) do
      {:ok, bill} ->
        Repo.one(
          from t in Transaction,
            where: t.credit_card_bill_id == ^bill.id,
            select: coalesce(sum(t.amount), 0)
        ) |> to_decimal()

      _ ->
        Decimal.new(0)
    end
  end

  def available_limit(%CreditCard{} = card) do
    used = current_balance(card)
    Decimal.sub(card.limit, used)
  end

  # Calcula o mês de referência da fatura atual.
  # Se hoje é antes do closing_day, a fatura é do mês atual.
  # Se hoje é no closing_day ou depois, a fatura é do próximo mês.
  defp current_reference_month(%CreditCard{closing_day: closing_day}, today) do
    if today.day < closing_day do
      Date.beginning_of_month(today)
    else
      next_month = Date.add(today, 32 - today.day)
      Date.beginning_of_month(next_month)
    end
  end

  defp to_decimal(nil), do: Decimal.new(0)
  defp to_decimal(v) when is_float(v), do: Decimal.from_float(v)
  defp to_decimal(v) when is_integer(v), do: Decimal.new(v)
  defp to_decimal(%Decimal{} = v), do: v

  defp create_open_bill(%CreditCard{} = card, reference_month, _today) do
    closing_date = %{reference_month | day: min(card.closing_day, Date.days_in_month(reference_month))}
    # due_date no mês seguinte ao fechamento
    next_month = Date.add(closing_date, 32 - closing_date.day)
    due_date = %{next_month | day: min(card.due_day, Date.days_in_month(next_month))}

    %CreditCardBill{}
    |> CreditCardBill.changeset(%{
      credit_card_id: card.id,
      reference_month: reference_month,
      closing_date: closing_date,
      due_date: due_date,
      status: "open",
      total_amount: Decimal.new(0)
    })
    |> Repo.insert()
  end
end
