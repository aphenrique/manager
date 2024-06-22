defmodule ManagerWeb.TransactionHTML do
  use ManagerWeb, :html

  embed_templates "transaction_html/*"

  @doc """
  Renders a transaction form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def transaction_form(assigns)
end
