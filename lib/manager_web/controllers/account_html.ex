defmodule ManagerWeb.AccountHTML do
  use ManagerWeb, :html

  embed_templates "account_html/*"

  @doc """
  Renders a account form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def account_form(assigns)

  def user_opts(changeset) do
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:users, [])
      |> Enum.map(& &1.data.id)

    Manager.Users.get_user!(existing_ids)
  end
end
