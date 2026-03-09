defmodule ManagerWeb.AccountsLive.Show do
  use ManagerWeb, :live_view

  alias Manager.Finance.{Accounts, Transactions}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    account = Accounts.get_account!(id)
    balance = Accounts.current_balance(account)
    today = Date.utc_today()
    transactions = Transactions.list_transactions(%{account_id: id, month: {today.year, today.month}})

    {:ok,
     socket
     |> assign(:page_title, account.name)
     |> assign(:account, account)
     |> assign(:balance, balance)
     |> assign(:transactions, transactions)
     |> assign(:current_month, today)}
  end

  @impl true
  def handle_event("prev-month", _params, socket) do
    current = socket.assigns.current_month
    prev = if current.month == 1 do
      Date.new!(current.year - 1, 12, 1)
    else
      Date.new!(current.year, current.month - 1, 1)
    end
    transactions = Transactions.list_transactions(%{account_id: socket.assigns.account.id, month: {prev.year, prev.month}})
    {:noreply, socket |> assign(:current_month, prev) |> assign(:transactions, transactions)}
  end

  def handle_event("next-month", _params, socket) do
    current = socket.assigns.current_month
    next = if current.month == 12 do
      Date.new!(current.year + 1, 1, 1)
    else
      Date.new!(current.year, current.month + 1, 1)
    end
    transactions = Transactions.list_transactions(%{account_id: socket.assigns.account.id, month: {next.year, next.month}})
    {:noreply, socket |> assign(:current_month, next) |> assign(:transactions, transactions)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center gap-3">
        <.link href={~p"/accounts"} class="btn btn-ghost btn-sm gap-1">
          <.icon name="hero-arrow-left" class="size-4" />
          Contas
        </.link>
        <h1 class="text-2xl font-bold text-base-content">{@account.name}</h1>
      </div>

      <div class="card bg-base-200 border border-base-300">
        <div class="card-body p-4">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-base-content/60">Saldo atual</p>
              <p class={[
                "text-3xl font-bold",
                if(Decimal.compare(@balance, Decimal.new(0)) == :lt, do: "text-error", else: "text-success")
              ]}>
                {format_currency(@balance)}
              </p>
            </div>
            <.link href={~p"/transactions/new"} class="btn btn-primary btn-sm gap-2">
              <.icon name="hero-plus" class="size-4" />
              Lançar
            </.link>
          </div>
        </div>
      </div>

      <div class="card bg-base-200 border border-base-300">
        <div class="card-body p-4">
          <div class="flex items-center justify-between mb-4">
            <button phx-click="prev-month" class="btn btn-ghost btn-xs">
              <.icon name="hero-chevron-left" class="size-4" />
            </button>
            <h2 class="font-semibold text-base-content">
              {Calendar.strftime(@current_month, "%B %Y")}
            </h2>
            <button phx-click="next-month" class="btn btn-ghost btn-xs">
              <.icon name="hero-chevron-right" class="size-4" />
            </button>
          </div>

          <div class="space-y-1">
            <%= for t <- @transactions do %>
              <div class="flex items-center justify-between py-2 border-b border-base-300/50 last:border-0">
                <div class="flex items-center gap-3">
                  <div class={["w-8 h-8 rounded-full flex items-center justify-center",
                    if(t.type == "income" or (t.type == "transfer" and t.incoming_transfer), do: "bg-success/10", else: "bg-error/10")]}>
                    <.icon name={cond do
                        t.type == "income" -> "hero-arrow-up"
                        t.type == "transfer" and t.incoming_transfer -> "hero-arrow-down-left"
                        t.type == "transfer" -> "hero-arrow-up-right"
                        true -> "hero-arrow-down"
                      end}
                      class={["size-4", if(t.type == "income" or (t.type == "transfer" and t.incoming_transfer), do: "text-success", else: "text-error")]} />
                  </div>
                  <div>
                    <p class="text-sm text-base-content">{t.description}</p>
                    <p class="text-xs text-base-content/50">
                      {Calendar.strftime(t.date, "%d/%m/%Y")}
                      <%= if t.category do %> · {t.category.name}<% end %>
                    </p>
                  </div>
                </div>
                <span class={["text-sm font-semibold", if(t.type == "income" or (t.type == "transfer" and t.incoming_transfer), do: "text-success", else: "text-error")]}>
                  {if t.type == "income" or (t.type == "transfer" and t.incoming_transfer), do: "+", else: "-"}{format_currency(t.amount)}
                </span>
              </div>
            <% end %>
            <%= if Enum.empty?(@transactions) do %>
              <p class="text-center text-sm text-base-content/50 py-6">Sem transações neste período</p>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

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
