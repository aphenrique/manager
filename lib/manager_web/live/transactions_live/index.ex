defmodule ManagerWeb.TransactionsLive.Index do
  use ManagerWeb, :live_view

  alias Manager.Finance.Transactions

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today()
    transactions = Transactions.list_transactions(%{month: {today.year, today.month}})

    {:ok,
     socket
     |> assign(:page_title, "Transações")
     |> assign(:transactions, transactions)
     |> assign(:current_month, today)
     |> assign(:filter_type, nil)}
  end

  @impl true
  def handle_event("prev-month", _params, socket) do
    current = socket.assigns.current_month
    prev = if current.month == 1, do: Date.new!(current.year - 1, 12, 1), else: Date.new!(current.year, current.month - 1, 1)
    transactions = Transactions.list_transactions(%{month: {prev.year, prev.month}, type: socket.assigns.filter_type})
    {:noreply, socket |> assign(:current_month, prev) |> assign(:transactions, transactions)}
  end

  def handle_event("next-month", _params, socket) do
    current = socket.assigns.current_month
    next = if current.month == 12, do: Date.new!(current.year + 1, 1, 1), else: Date.new!(current.year, current.month + 1, 1)
    transactions = Transactions.list_transactions(%{month: {next.year, next.month}, type: socket.assigns.filter_type})
    {:noreply, socket |> assign(:current_month, next) |> assign(:transactions, transactions)}
  end

  def handle_event("filter-type", %{"type" => type}, socket) do
    type_value = if type == "", do: nil, else: type
    current = socket.assigns.current_month
    transactions = Transactions.list_transactions(%{month: {current.year, current.month}, type: type_value})
    {:noreply, socket |> assign(:filter_type, type_value) |> assign(:transactions, transactions)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Transactions.get_transaction!(id)
    {:ok, _} = Transactions.delete_transaction(transaction)
    current = socket.assigns.current_month
    transactions = Transactions.list_transactions(%{month: {current.year, current.month}, type: socket.assigns.filter_type})
    {:noreply, socket |> put_flash(:info, "Transação removida.") |> assign(:transactions, transactions)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold text-base-content">Transações</h1>
        <.link href={~p"/transactions/new"} class="btn btn-primary btn-sm gap-2">
          <.icon name="hero-plus" class="size-4" />
          Nova Transação
        </.link>
      </div>

      <%!-- Filters --%>
      <div class="flex items-center gap-3">
        <div class="flex gap-1">
          <button phx-click="prev-month" class="btn btn-ghost btn-xs">
            <.icon name="hero-chevron-left" class="size-4" />
          </button>
          <span class="btn btn-ghost btn-xs pointer-events-none">
            {Calendar.strftime(@current_month, "%B %Y")}
          </span>
          <button phx-click="next-month" class="btn btn-ghost btn-xs">
            <.icon name="hero-chevron-right" class="size-4" />
          </button>
        </div>

        <select phx-change="filter-type" name="type" class="select select-bordered select-xs">
          <option value="">Todos os tipos</option>
          <option value="income">Receitas</option>
          <option value="expense">Despesas</option>
          <option value="transfer">Transferências</option>
        </select>
      </div>

      <%!-- Transaction list --%>
      <div class="card bg-base-200 border border-base-300">
        <div class="card-body p-4">
          <div class="space-y-1">
            <%= for t <- @transactions do %>
              <div class="flex items-center justify-between py-2 border-b border-base-300/50 last:border-0 group">
                <div class="flex items-center gap-3">
                  <div class={["w-8 h-8 rounded-full flex items-center justify-center shrink-0",
                    case t.type do
                      "income" -> "bg-success/10"
                      "transfer" -> "bg-info/10"
                      _ -> "bg-error/10"
                    end]}>
                    <.icon name={case t.type do "income" -> "hero-arrow-up"; "transfer" -> "hero-arrow-right"; _ -> "hero-arrow-down" end}
                      class={["size-4", case t.type do "income" -> "text-success"; "transfer" -> "text-info"; _ -> "text-error" end]} />
                  </div>
                  <div>
                    <p class="text-sm text-base-content">{t.description}</p>
                    <p class="text-xs text-base-content/50">
                      {Calendar.strftime(t.date, "%d/%m/%Y")}
                      <%= if t.account do %> · {t.account.name}<% end %>
                      <%= if t.credit_card do %> · {t.credit_card.name}<% end %>
                      <%= if t.category do %> · {t.category.name}<% end %>
                    </p>
                  </div>
                </div>
                <div class="flex items-center gap-3">
                  <span class={["text-sm font-semibold",
                    case t.type do "income" -> "text-success"; "transfer" -> "text-info"; _ -> "text-error" end]}>
                    {if t.type == "income", do: "+", else: "-"}{format_currency(t.amount)}
                  </span>
                  <button phx-click="delete" phx-value-id={t.id}
                    class="btn btn-ghost btn-xs opacity-0 group-hover:opacity-100 text-error"
                    data-confirm="Remover esta transação?">
                    <.icon name="hero-trash" class="size-3" />
                  </button>
                </div>
              </div>
            <% end %>
            <%= if Enum.empty?(@transactions) do %>
              <p class="text-center text-sm text-base-content/50 py-8">Sem transações neste período</p>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp format_currency(amount) when is_nil(amount), do: "R$ 0,00"
  defp format_currency(amount) do
    value = Decimal.to_float(amount)
    abs_value = abs(value)
    formatted = :erlang.float_to_binary(abs_value, decimals: 2)
    [integer_part, decimal_part] = String.split(formatted, ".")
    integer_with_sep = integer_part |> String.graphemes() |> Enum.reverse() |> Enum.chunk_every(3) |> Enum.join(".") |> String.graphemes() |> Enum.reverse() |> Enum.join()
    "R$ #{integer_with_sep},#{decimal_part}"
  end
end
