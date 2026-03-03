defmodule ManagerWeb.DashboardLive do
  use ManagerWeb, :live_view

  alias Manager.Finance.{Accounts, Transactions, CreditCards}

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today()

    accounts = Accounts.list_accounts_with_balance()
    credit_cards = CreditCards.list_credit_cards()
    recent = Transactions.recent_transactions(8)
    summary = Transactions.monthly_summary(today.year, today.month)
    breakdown = Transactions.category_breakdown(today.year, today.month)

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:accounts, accounts)
     |> assign(:credit_cards, credit_cards)
     |> assign(:recent_transactions, recent)
     |> assign(:summary, summary)
     |> assign(:category_breakdown, breakdown)
     |> assign(:current_month, today)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <%!-- Page header --%>
      <div>
        <h1 class="text-2xl font-bold text-base-content">Dashboard</h1>
        <p class="text-sm text-base-content/60 mt-1">
          {Calendar.strftime(@current_month, "%B %Y")}
        </p>
      </div>

      <%!-- Monthly summary cards --%>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <div class="flex items-center justify-between">
              <span class="text-sm text-base-content/60">Receitas do Mês</span>
              <.icon name="hero-arrow-trending-up" class="size-5 text-success" />
            </div>
            <p class="text-2xl font-bold text-success mt-1">
              {format_currency(@summary.income)}
            </p>
          </div>
        </div>

        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <div class="flex items-center justify-between">
              <span class="text-sm text-base-content/60">Gastos do Mês</span>
              <.icon name="hero-arrow-trending-down" class="size-5 text-error" />
            </div>
            <p class="text-2xl font-bold text-error mt-1">
              {format_currency(@summary.expense)}
            </p>
          </div>
        </div>

        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <div class="flex items-center justify-between">
              <span class="text-sm text-base-content/60">Saldo do Mês</span>
              <.icon name="hero-scale" class="size-5 text-primary" />
            </div>
            <p class={[
              "text-2xl font-bold mt-1",
              if(Decimal.compare(Decimal.sub(@summary.income, @summary.expense), Decimal.new(0)) == :lt,
                do: "text-error",
                else: "text-success"
              )
            ]}>
              {format_currency(Decimal.sub(@summary.income, @summary.expense))}
            </p>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <%!-- Accounts --%>
        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <div class="flex items-center justify-between mb-3">
              <h2 class="font-semibold text-base-content">Contas</h2>
              <.link href={~p"/accounts"} class="btn btn-ghost btn-xs">Ver todas</.link>
            </div>
            <div class="space-y-2">
              <%= for account <- @accounts do %>
                <.link href={~p"/accounts/#{account.id}"} class="flex items-center justify-between p-2 rounded-lg hover:bg-base-300 transition-colors">
                  <div class="flex items-center gap-2">
                    <div class="w-8 h-8 rounded-full flex items-center justify-center" style={"background-color: #{account.color}20; color: #{account.color}"}>
                      <.icon name="hero-building-library" class="size-4" />
                    </div>
                    <span class="text-sm text-base-content">{account.name}</span>
                  </div>
                  <span class={[
                    "text-sm font-semibold",
                    if(Decimal.compare(account.balance, Decimal.new(0)) == :lt, do: "text-error", else: "text-base-content")
                  ]}>
                    {format_currency(account.balance)}
                  </span>
                </.link>
              <% end %>
              <%= if Enum.empty?(@accounts) do %>
                <p class="text-sm text-base-content/50 text-center py-4">Nenhuma conta cadastrada</p>
              <% end %>
            </div>
          </div>
        </div>

        <%!-- Category breakdown --%>
        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <div class="flex items-center justify-between mb-3">
              <h2 class="font-semibold text-base-content">Gastos por Categoria</h2>
              <.link href={~p"/reports"} class="btn btn-ghost btn-xs">Relatórios</.link>
            </div>
            <div class="space-y-2">
              <%= for item <- Enum.take(@category_breakdown, 5) do %>
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-2">
                    <div class="w-3 h-3 rounded-full" style={"background-color: #{item.category_color}"}></div>
                    <span class="text-sm text-base-content/80">{item.category_name}</span>
                  </div>
                  <span class="text-sm font-medium text-error">{format_currency(item.total)}</span>
                </div>
              <% end %>
              <%= if Enum.empty?(@category_breakdown) do %>
                <p class="text-sm text-base-content/50 text-center py-4">Sem gastos no mês</p>
              <% end %>
            </div>
          </div>
        </div>
      </div>

      <%!-- Credit cards --%>
      <%= unless Enum.empty?(@credit_cards) do %>
        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <div class="flex items-center justify-between mb-3">
              <h2 class="font-semibold text-base-content">Cartões de Crédito</h2>
              <.link href={~p"/credit-cards"} class="btn btn-ghost btn-xs">Ver todos</.link>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <%= for card <- @credit_cards do %>
                <.link href={~p"/credit-cards/#{card.id}"} class="p-3 rounded-lg border border-base-300 hover:bg-base-300 transition-colors block">
                  <div class="flex items-center justify-between mb-2">
                    <span class="text-sm font-medium text-base-content">{card.name}</span>
                    <span style={"color: #{card.color}"}><.icon name="hero-credit-card" class="size-4" /></span>
                  </div>
                  <p class="text-xs text-base-content/50">
                    Fecha dia {card.closing_day} · Vence dia {card.due_day}
                  </p>
                </.link>
              <% end %>
            </div>
          </div>
        </div>
      <% end %>

      <%!-- Recent transactions --%>
      <div class="card bg-base-200 border border-base-300">
        <div class="card-body p-4">
          <div class="flex items-center justify-between mb-3">
            <h2 class="font-semibold text-base-content">Transações Recentes</h2>
            <.link href={~p"/transactions"} class="btn btn-ghost btn-xs">Ver todas</.link>
          </div>
          <div class="space-y-1">
            <%= for t <- @recent_transactions do %>
              <div class="flex items-center justify-between py-2 border-b border-base-300/50 last:border-0">
                <div class="flex items-center gap-3">
                  <div class={[
                    "w-8 h-8 rounded-full flex items-center justify-center",
                    if(t.type == "income", do: "bg-success/10", else: "bg-error/10")
                  ]}>
                    <.icon
                      name={if t.type == "income", do: "hero-arrow-up", else: "hero-arrow-down"}
                      class={["size-4", if(t.type == "income", do: "text-success", else: "text-error")]}
                    />
                  </div>
                  <div>
                    <p class="text-sm text-base-content">{t.description}</p>
                    <p class="text-xs text-base-content/50">
                      {Calendar.strftime(t.date, "%d/%m/%Y")}
                      <%= if t.category do %>
                        · {t.category.name}
                      <% end %>
                    </p>
                  </div>
                </div>
                <span class={["text-sm font-semibold", if(t.type == "income", do: "text-success", else: "text-error")]}>
                  {if t.type == "income", do: "+", else: "-"}{format_currency(t.amount)}
                </span>
              </div>
            <% end %>
            <%= if Enum.empty?(@recent_transactions) do %>
              <p class="text-sm text-base-content/50 text-center py-6">Nenhuma transação ainda</p>
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
    sign = if value < 0, do: "-", else: ""
    formatted = :erlang.float_to_binary(abs_value, decimals: 2)
    [integer_part, decimal_part] = String.split(formatted, ".")
    integer_with_sep = integer_part |> String.graphemes() |> Enum.reverse() |> Enum.chunk_every(3) |> Enum.join(".") |> String.graphemes() |> Enum.reverse() |> Enum.join()
    "#{sign}R$ #{integer_with_sep},#{decimal_part}"
  end
end
