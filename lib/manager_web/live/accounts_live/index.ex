defmodule ManagerWeb.AccountsLive.Index do
  use ManagerWeb, :live_view

  alias Manager.Finance.{Accounts, Account}

  @impl true
  def mount(_params, _session, socket) do
    accounts = Accounts.list_accounts_with_balance()
    {:ok,
     socket
     |> assign(:page_title, "Contas")
     |> assign(:accounts, accounts)
     |> assign(:form, nil)}
  end

  @impl true
  def handle_event("new", _params, socket) do
    changeset = Accounts.change_account(%Account{})
    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, :form, nil)}
  end

  def handle_event("save", %{"account" => params}, socket) do
    case Accounts.create_account(params) do
      {:ok, _account} ->
        accounts = Accounts.list_accounts_with_balance()
        {:noreply,
         socket
         |> put_flash(:info, "Conta criada com sucesso!")
         |> assign(:accounts, accounts)
         |> assign(:form, nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    account = Accounts.get_account!(id)
    {:ok, _} = Accounts.delete_account(account)
    accounts = Accounts.list_accounts_with_balance()
    {:noreply,
     socket
     |> put_flash(:info, "Conta removida.")
     |> assign(:accounts, accounts)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-bold text-base-content">Contas</h1>
          <p class="text-sm text-base-content/60 mt-1">{length(@accounts)} conta(s) cadastrada(s)</p>
        </div>
        <button phx-click="new" class="btn btn-primary btn-sm gap-2">
          <.icon name="hero-plus" class="size-4" />
          Nova Conta
        </button>
      </div>

      <%!-- Form modal --%>
      <%= if @form do %>
        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <h2 class="font-semibold text-base-content mb-4">Nova Conta</h2>
            <.form for={@form} phx-submit="save" class="space-y-4">
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div class="col-span-2">
                  <.input field={@form[:name]} label="Nome" placeholder="Ex: Conta Corrente Itaú" />
                </div>
                <div>
                  <.input field={@form[:type]} type="select" label="Tipo"
                    options={[{"Conta Corrente", "checking"}, {"Poupança", "savings"}, {"Investimento", "investment"}, {"Carteira", "wallet"}]} />
                </div>
                <div>
                  <.input field={@form[:initial_balance]} type="number" label="Saldo Inicial" step="0.01" placeholder="0.00" />
                </div>
                <div>
                  <.input field={@form[:color]} type="color" label="Cor" value="#6366f1" />
                </div>
              </div>
              <div class="flex gap-2 justify-end">
                <button type="button" phx-click="cancel" class="btn btn-ghost btn-sm">Cancelar</button>
                <button type="submit" class="btn btn-primary btn-sm">Salvar</button>
              </div>
            </.form>
          </div>
        </div>
      <% end %>

      <%!-- Account list --%>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <%= for account <- @accounts do %>
          <div class="card bg-base-200 border border-base-300 hover:border-base-content/20 transition-colors">
            <div class="card-body p-4">
              <div class="flex items-start justify-between">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-full flex items-center justify-center" style={"background-color: #{account.color}20; color: #{account.color}"}>
                    <.icon name="hero-building-library" class="size-5" />
                  </div>
                  <div>
                    <h3 class="font-semibold text-base-content">{account.name}</h3>
                    <p class="text-xs text-base-content/50">{account_type_label(account.type)}</p>
                  </div>
                </div>
                <div class="dropdown dropdown-end">
                  <button tabindex="0" class="btn btn-ghost btn-xs">
                    <.icon name="hero-ellipsis-vertical" class="size-4" />
                  </button>
                  <ul tabindex="0" class="dropdown-content menu bg-base-300 rounded-box z-50 w-32 p-1 shadow">
                    <li><.link href={~p"/accounts/#{account.id}"}>Ver extrato</.link></li>
                    <li><button phx-click="delete" phx-value-id={account.id} class="text-error">Remover</button></li>
                  </ul>
                </div>
              </div>
              <div class="mt-4">
                <p class="text-xs text-base-content/50">Saldo atual</p>
                <p class={[
                  "text-xl font-bold",
                  if(Decimal.compare(account.balance, Decimal.new(0)) == :lt, do: "text-error", else: "text-base-content")
                ]}>
                  {format_currency(account.balance)}
                </p>
              </div>
              <div class="mt-2">
                <.link href={~p"/accounts/#{account.id}"} class="btn btn-ghost btn-xs w-full">
                  Ver extrato →
                </.link>
              </div>
            </div>
          </div>
        <% end %>

        <%= if Enum.empty?(@accounts) do %>
          <div class="col-span-3 text-center py-12 text-base-content/50">
            <.icon name="hero-building-library" class="size-12 mx-auto mb-3 opacity-30" />
            <p>Nenhuma conta cadastrada.</p>
            <button phx-click="new" class="btn btn-primary btn-sm mt-3">Criar primeira conta</button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp account_type_label("checking"), do: "Conta Corrente"
  defp account_type_label("savings"), do: "Poupança"
  defp account_type_label("investment"), do: "Investimento"
  defp account_type_label("wallet"), do: "Carteira"
  defp account_type_label(_), do: "Conta"

  defp format_currency(amount) when is_nil(amount), do: "R$ 0,00"
  defp format_currency(amount) when is_integer(amount), do: format_currency(Decimal.new(amount))
  defp format_currency(amount) when is_float(amount), do: format_currency(Decimal.from_float(amount))
  defp format_currency(amount) do
    value = Decimal.to_float(amount)
    abs_value = abs(value)
    sign = if value < 0, do: "-", else: ""
    formatted = :erlang.float_to_binary(abs_value, decimals: 2)
    [integer_part, decimal_part] = String.split(formatted, ".")
    integer_with_sep = integer_part |> String.graphemes() |> Enum.reverse() |> Enum.chunk_every(3) |> Enum.join(".") |> String.graphemes() |> Enum.reverse() |> Enum.join()
    "#{sign}R$ #{integer_with_sep},#{decimal_part}"
  end
end
