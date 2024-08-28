defmodule ManagerWeb.TransactionHTML do
  use ManagerWeb, :html
  alias Manager.{Transactions, Accounts}

  embed_templates "transaction_html/*"

  @doc """
  Renders a transaction form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def transaction_form(assigns)

  def category_opts(changeset) do
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:categories, [])
      |> Enum.map(& &1.data.id)

    for cat <- Transactions.list_categories(),
        do: [key: cat.name, value: cat.id, selected: cat.id in existing_ids]
  end

  def supplier_opts(changeset) do
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:suppliers, [])
      |> Enum.map(& &1.data.id)

    for sup <- Transactions.list_suppliers(),
        do: [key: sup.name, value: sup.id, selected: sup.id in existing_ids]
  end

  def account_opts(changeset) do
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:accounts, [])
      |> Enum.map(& &1.data.id)

    for acc <- Accounts.list_accounts(),
        do: [key: acc.name, value: acc.id, selected: acc.id in existing_ids]
  end
end
