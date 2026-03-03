defmodule ManagerWeb.ReportsLive do
  use ManagerWeb, :live_view

  alias Manager.Finance.Transactions

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today()
    summary = Transactions.monthly_summary(today.year, today.month)
    breakdown = Transactions.category_breakdown(today.year, today.month)
    trend = Transactions.spending_trend(6)

    {:ok,
     socket
     |> assign(:page_title, "Relatórios")
     |> assign(:current_month, today)
     |> assign(:summary, summary)
     |> assign(:breakdown, breakdown)
     |> assign(:trend, trend)}
  end

  @impl true
  def handle_event("prev-month", _params, socket) do
    current = socket.assigns.current_month
    prev = if current.month == 1, do: Date.new!(current.year - 1, 12, 1), else: Date.new!(current.year, current.month - 1, 1)
    {:noreply, load_month(socket, prev)}
  end

  def handle_event("next-month", _params, socket) do
    current = socket.assigns.current_month
    next = if current.month == 12, do: Date.new!(current.year + 1, 1, 1), else: Date.new!(current.year, current.month + 1, 1)
    {:noreply, load_month(socket, next)}
  end

  defp load_month(socket, date) do
    summary = Transactions.monthly_summary(date.year, date.month)
    breakdown = Transactions.category_breakdown(date.year, date.month)

    socket
    |> assign(:current_month, date)
    |> assign(:summary, summary)
    |> assign(:breakdown, breakdown)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold text-base-content">Relatórios</h1>
        <div class="flex gap-1 items-center">
          <button phx-click="prev-month" class="btn btn-ghost btn-xs">
            <.icon name="hero-chevron-left" class="size-4" />
          </button>
          <span class="text-sm font-medium text-base-content px-2">
            {Calendar.strftime(@current_month, "%B %Y")}
          </span>
          <button phx-click="next-month" class="btn btn-ghost btn-xs">
            <.icon name="hero-chevron-right" class="size-4" />
          </button>
        </div>
      </div>

      <%!-- Summary --%>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <p class="text-sm text-base-content/60">Receitas</p>
            <p class="text-2xl font-bold text-success">{format_currency(@summary.income)}</p>
          </div>
        </div>
        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <p class="text-sm text-base-content/60">Despesas</p>
            <p class="text-2xl font-bold text-error">{format_currency(@summary.expense)}</p>
          </div>
        </div>
        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <p class="text-sm text-base-content/60">Resultado</p>
            <p class={["text-2xl font-bold",
              if(Decimal.compare(Decimal.sub(@summary.income, @summary.expense), 0) == :lt, do: "text-error", else: "text-success")]}>
              {format_currency(Decimal.sub(@summary.income, @summary.expense))}
            </p>
          </div>
        </div>
      </div>

      <%!-- Spending trend --%>
      <div class="card bg-base-200 border border-base-300">
        <div class="card-body p-4">
          <h2 class="font-semibold text-base-content mb-4">Evolução dos Últimos 6 Meses</h2>
          <div class="overflow-x-auto">
            <table class="table table-xs">
              <thead>
                <tr>
                  <th class="text-base-content/60">Mês</th>
                  <th class="text-right text-success">Receitas</th>
                  <th class="text-right text-error">Despesas</th>
                  <th class="text-right text-base-content/60">Resultado</th>
                </tr>
              </thead>
              <tbody>
                <%= for month <- @trend do %>
                  <tr class="hover:bg-base-300">
                    <td class="text-base-content">{month_name(month.month)} {month.year}</td>
                    <td class="text-right text-success">{format_currency(month.income)}</td>
                    <td class="text-right text-error">{format_currency(month.expense)}</td>
                    <td class={["text-right font-medium",
                      if(Decimal.compare(Decimal.sub(month.income, month.expense), 0) == :lt, do: "text-error", else: "text-success")]}>
                      {format_currency(Decimal.sub(month.income, month.expense))}
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <%!-- Category breakdown --%>
      <div class="card bg-base-200 border border-base-300">
        <div class="card-body p-4">
          <h2 class="font-semibold text-base-content mb-4">Gastos por Categoria</h2>
          <%= if Enum.empty?(@breakdown) do %>
            <p class="text-sm text-base-content/50 text-center py-6">Sem gastos com categoria no período</p>
          <% else %>
            <div class="space-y-3">
              <% total_expense = Enum.reduce(@breakdown, Decimal.new(0), &Decimal.add(&2, &1.total)) %>
              <%= for item <- @breakdown do %>
                <div>
                  <div class="flex items-center justify-between mb-1">
                    <div class="flex items-center gap-2">
                      <div class="w-3 h-3 rounded-full" style={"background-color: #{item.category_color}"}></div>
                      <span class="text-sm text-base-content">{item.category_name}</span>
                    </div>
                    <span class="text-sm font-medium text-error">{format_currency(item.total)}</span>
                  </div>
                  <div class="w-full bg-base-300 rounded-full h-1.5">
                    <div class="h-1.5 rounded-full" style={"background-color: #{item.category_color}; width: #{percent(item.total, total_expense)}%"}></div>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp percent(value, total) do
    if Decimal.compare(total, 0) == :eq do
      0
    else
      value |> Decimal.div(total) |> Decimal.mult(100) |> Decimal.to_float() |> round()
    end
  end

  defp month_name(1), do: "Jan"
  defp month_name(2), do: "Fev"
  defp month_name(3), do: "Mar"
  defp month_name(4), do: "Abr"
  defp month_name(5), do: "Mai"
  defp month_name(6), do: "Jun"
  defp month_name(7), do: "Jul"
  defp month_name(8), do: "Ago"
  defp month_name(9), do: "Set"
  defp month_name(10), do: "Out"
  defp month_name(11), do: "Nov"
  defp month_name(12), do: "Dez"

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
