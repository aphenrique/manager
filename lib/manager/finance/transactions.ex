defmodule Manager.Finance.Transactions do
  import Ecto.Query
  alias Manager.Repo
  alias Manager.Finance.{Transaction, CreditCards}

  def list_transactions(filters \\ %{}) do
    Transaction
    |> apply_filters(filters)
    |> preload([:account, :credit_card, :category, :credit_card_bill])
    |> order_by([t], desc: t.date, desc: t.inserted_at)
    |> Repo.all()
  end

  def get_transaction!(id) do
    Repo.get!(Transaction, id)
    |> Repo.preload([:account, :credit_card, :category])
  end

  def create_transaction(attrs \\ %{}) do
    result =
      %Transaction{}
      |> Transaction.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, transaction} ->
        # Se for gasto no cartão, associar à fatura aberta
        if transaction.credit_card_id && is_nil(transaction.credit_card_bill_id) do
          attach_to_open_bill(transaction)
        else
          {:ok, transaction}
        end

      error ->
        error
    end
  end

  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  # Resumo mensal: total de receitas e despesas para um dado mês
  def monthly_summary(year, month) do
    start_date = Date.new!(year, month, 1)
    end_date = Date.end_of_month(start_date)

    rows =
      Repo.all(
        from t in Transaction,
          where: t.date >= ^start_date and t.date <= ^end_date and t.type in ["income", "expense"],
          group_by: t.type,
          select: {t.type, coalesce(sum(t.amount), 0)}
      )

    %{
      income: find_amount(rows, "income"),
      expense: find_amount(rows, "expense")
    }
  end

  # Gastos agrupados por categoria em um dado mês
  def category_breakdown(year, month) do
    start_date = Date.new!(year, month, 1)
    end_date = Date.end_of_month(start_date)

    Repo.all(
      from t in Transaction,
        join: c in assoc(t, :category),
        where:
          t.date >= ^start_date and t.date <= ^end_date and t.type == "expense" and
            not is_nil(t.category_id),
        group_by: [c.id, c.name, c.color],
        select: %{
          category_id: c.id,
          category_name: c.name,
          category_color: c.color,
          total: coalesce(sum(t.amount), 0)
        },
        order_by: [desc: coalesce(sum(t.amount), 0)]
    )
  end

  # Tendência de gastos dos últimos N meses
  def spending_trend(months \\ 6) do
    today = Date.utc_today()

    Enum.map(0..(months - 1), fn i ->
      # Calcula o mês retroativo
      total_months = today.month - 1 - i
      year = today.year + div(total_months, 12)
      month = rem(total_months, 12) + 1
      {year, month} = if month <= 0, do: {year - 1, month + 12}, else: {year, month}

      summary = monthly_summary(year, month)
      Map.merge(summary, %{year: year, month: month})
    end)
    |> Enum.reverse()
  end

  # Últimas N transações
  def recent_transactions(limit \\ 10) do
    Transaction
    |> preload([:account, :credit_card, :category])
    |> order_by([t], desc: t.date, desc: t.inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {:account_id, id}, q when not is_nil(id) ->
        where(q, [t], t.account_id == ^id)

      {:credit_card_id, id}, q when not is_nil(id) ->
        where(q, [t], t.credit_card_id == ^id)

      {:category_id, id}, q when not is_nil(id) ->
        where(q, [t], t.category_id == ^id)

      {:type, type}, q when not is_nil(type) ->
        where(q, [t], t.type == ^type)

      {:date_from, date}, q when not is_nil(date) ->
        where(q, [t], t.date >= ^date)

      {:date_to, date}, q when not is_nil(date) ->
        where(q, [t], t.date <= ^date)

      {:month, {year, month}}, q ->
        start_date = Date.new!(year, month, 1)
        end_date = Date.end_of_month(start_date)
        where(q, [t], t.date >= ^start_date and t.date <= ^end_date)

      _, q ->
        q
    end)
  end

  defp find_amount(rows, type) do
    case Enum.find(rows, fn {t, _} -> t == type end) do
      {_, amount} -> amount
      nil -> Decimal.new(0)
    end
  end

  defp attach_to_open_bill(%Transaction{credit_card_id: card_id} = transaction) do
    card = Repo.get!(Manager.Finance.CreditCard, card_id)

    case CreditCards.get_or_create_open_bill(card) do
      {:ok, bill} ->
        transaction
        |> Transaction.changeset(%{credit_card_bill_id: bill.id})
        |> Repo.update()

      _ ->
        {:ok, transaction}
    end
  end
end
