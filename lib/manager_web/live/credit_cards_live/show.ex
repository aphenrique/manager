defmodule ManagerWeb.CreditCardsLive.Show do
  use ManagerWeb, :live_view

  alias Manager.Finance.{CreditCards, Transactions}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    card = CreditCards.get_credit_card!(id)
    {:ok, open_bill} = CreditCards.get_or_create_open_bill(card)
    bills = CreditCards.list_bills(card)
    bill_transactions = Transactions.list_transactions(%{credit_card_bill_id: open_bill.id})
    balance = CreditCards.current_balance(card)
    available = CreditCards.available_limit(card)

    {:ok,
     socket
     |> assign(:page_title, card.name)
     |> assign(:card, card)
     |> assign(:open_bill, open_bill)
     |> assign(:bills, bills)
     |> assign(:bill_transactions, bill_transactions)
     |> assign(:balance, balance)
     |> assign(:available, available)}
  end

  @impl true
  def handle_event("close-bill", _params, socket) do
    case CreditCards.close_bill(socket.assigns.open_bill) do
      {:ok, _bill} ->
        card = socket.assigns.card
        {:ok, new_open} = CreditCards.get_or_create_open_bill(card)
        {:noreply,
         socket
         |> put_flash(:info, "Fatura fechada com sucesso!")
         |> assign(:open_bill, new_open)
         |> assign(:bills, CreditCards.list_bills(card))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Erro ao fechar fatura.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center gap-3">
        <.link href={~p"/credit-cards"} class="btn btn-ghost btn-sm gap-1">
          <.icon name="hero-arrow-left" class="size-4" />
          Cartões
        </.link>
        <h1 class="text-2xl font-bold text-base-content">{@card.name}</h1>
      </div>

      <%!-- Card summary --%>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <p class="text-sm text-base-content/60">Fatura Atual</p>
            <p class="text-2xl font-bold text-error">{format_currency(@balance)}</p>
          </div>
        </div>
        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <p class="text-sm text-base-content/60">Limite Disponível</p>
            <p class="text-2xl font-bold text-success">{format_currency(@available)}</p>
          </div>
        </div>
        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <p class="text-sm text-base-content/60">Limite Total</p>
            <p class="text-2xl font-bold text-base-content">{format_currency(@card.limit)}</p>
          </div>
        </div>
      </div>

      <%!-- Open bill --%>
      <div class="card bg-base-200 border border-base-300">
        <div class="card-body p-4">
          <div class="flex items-center justify-between mb-4">
            <div>
              <h2 class="font-semibold text-base-content">Fatura Aberta</h2>
              <p class="text-xs text-base-content/50">
                Fecha em {Calendar.strftime(@open_bill.closing_date, "%d/%m/%Y")} ·
                Vence em {Calendar.strftime(@open_bill.due_date, "%d/%m/%Y")}
              </p>
            </div>
            <div class="flex gap-2">
              <.link href={~p"/transactions/new"} class="btn btn-ghost btn-xs gap-1">
                <.icon name="hero-plus" class="size-3" />
                Lançar
              </.link>
              <button phx-click="close-bill" class="btn btn-warning btn-xs"
                data-confirm="Fechar a fatura atual?">
                Fechar Fatura
              </button>
            </div>
          </div>

          <div class="space-y-1">
            <%= for t <- @bill_transactions do %>
              <div class="flex items-center justify-between py-2 border-b border-base-300/50 last:border-0">
                <div>
                  <p class="text-sm text-base-content">{t.description}</p>
                  <p class="text-xs text-base-content/50">
                    {Calendar.strftime(t.date, "%d/%m/%Y")}
                    <%= if t.category do %> · {t.category.name}<% end %>
                  </p>
                </div>
                <span class="text-sm font-semibold text-error">{format_currency(t.amount)}</span>
              </div>
            <% end %>
            <%= if Enum.empty?(@bill_transactions) do %>
              <p class="text-center text-sm text-base-content/50 py-6">Sem lançamentos na fatura atual</p>
            <% end %>
          </div>
        </div>
      </div>

      <%!-- Bill history --%>
      <div class="card bg-base-200 border border-base-300">
        <div class="card-body p-4">
          <h2 class="font-semibold text-base-content mb-4">Histórico de Faturas</h2>
          <div class="space-y-2">
            <%= for bill <- @bills do %>
              <div class="flex items-center justify-between p-2 rounded-lg hover:bg-base-300">
                <div>
                  <p class="text-sm text-base-content">
                    {Calendar.strftime(bill.reference_month, "%B %Y")}
                  </p>
                  <p class="text-xs text-base-content/50">
                    Vence {Calendar.strftime(bill.due_date, "%d/%m/%Y")}
                  </p>
                </div>
                <div class="flex items-center gap-3">
                  <span class="text-sm font-semibold text-base-content">{format_currency(bill.total_amount)}</span>
                  <span class={["badge badge-sm",
                    case bill.status do
                      "open" -> "badge-info"
                      "closed" -> "badge-warning"
                      "paid" -> "badge-success"
                      _ -> "badge-ghost"
                    end
                  ]}>
                    {status_label(bill.status)}
                  </span>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp status_label("open"), do: "Aberta"
  defp status_label("closed"), do: "Fechada"
  defp status_label("paid"), do: "Paga"
  defp status_label(s), do: s

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
