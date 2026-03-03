defmodule ManagerWeb.CreditCardsLive.Index do
  use ManagerWeb, :live_view

  alias Manager.Finance.{CreditCards, CreditCard, Accounts}

  @impl true
  def mount(_params, _session, socket) do
    cards = CreditCards.list_credit_cards()
    accounts = Accounts.list_accounts()
    {:ok,
     socket
     |> assign(:page_title, "Cartões de Crédito")
     |> assign(:credit_cards, cards)
     |> assign(:accounts, accounts)
     |> assign(:form, nil)}
  end

  @impl true
  def handle_event("new", _params, socket) do
    changeset = CreditCards.change_credit_card(%CreditCard{})
    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, :form, nil)}
  end

  def handle_event("save", %{"credit_card" => params}, socket) do
    case CreditCards.create_credit_card(params) do
      {:ok, _card} ->
        cards = CreditCards.list_credit_cards()
        {:noreply,
         socket
         |> put_flash(:info, "Cartão criado com sucesso!")
         |> assign(:credit_cards, cards)
         |> assign(:form, nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-bold text-base-content">Cartões de Crédito</h1>
          <p class="text-sm text-base-content/60 mt-1">{length(@credit_cards)} cartão(ões) cadastrado(s)</p>
        </div>
        <button phx-click="new" class="btn btn-primary btn-sm gap-2">
          <.icon name="hero-plus" class="size-4" />
          Novo Cartão
        </button>
      </div>

      <%= if @form do %>
        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <h2 class="font-semibold text-base-content mb-4">Novo Cartão</h2>
            <.form for={@form} phx-submit="save" class="space-y-4">
              <div class="grid grid-cols-2 gap-4">
                <div class="col-span-2">
                  <.input field={@form[:name]} label="Nome do Cartão" placeholder="Ex: Nubank Roxinho" />
                </div>
                <div>
                  <.input field={@form[:limit]} type="number" label="Limite (R$)" step="0.01" placeholder="5000.00" />
                </div>
                <div>
                  <.input field={@form[:color]} type="color" label="Cor" value="#8b5cf6" />
                </div>
                <div>
                  <.input field={@form[:closing_day]} type="number" label="Dia de Fechamento" min="1" max="28" placeholder="15" />
                </div>
                <div>
                  <.input field={@form[:due_day]} type="number" label="Dia de Vencimento" min="1" max="31" placeholder="22" />
                </div>
                <div class="col-span-2">
                  <.input field={@form[:account_id]} type="select" label="Conta para Pagamento (opcional)"
                    options={[{"— Nenhuma —", nil}] ++ Enum.map(@accounts, &{&1.name, &1.id})} />
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

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <%= for card <- @credit_cards do %>
          <.link href={~p"/credit-cards/#{card.id}"} class="card bg-base-200 border border-base-300 hover:border-base-content/20 transition-colors block">
            <div class="card-body p-4">
              <div class="flex items-center justify-between mb-3">
                <div class="flex items-center gap-2">
                  <div class="w-8 h-8 rounded-lg flex items-center justify-center" style={"background-color: #{card.color}20; color: #{card.color}"}>
                    <.icon name="hero-credit-card" class="size-5" />
                  </div>
                  <h3 class="font-semibold text-base-content">{card.name}</h3>
                </div>
              </div>
              <div class="space-y-1 text-sm text-base-content/60">
                <div class="flex justify-between">
                  <span>Limite total</span>
                  <span class="text-base-content font-medium">{format_currency(card.limit)}</span>
                </div>
                <div class="flex justify-between">
                  <span>Fecha dia</span>
                  <span class="text-base-content">{card.closing_day}</span>
                </div>
                <div class="flex justify-between">
                  <span>Vence dia</span>
                  <span class="text-base-content">{card.due_day}</span>
                </div>
              </div>
            </div>
          </.link>
        <% end %>

        <%= if Enum.empty?(@credit_cards) do %>
          <div class="col-span-3 text-center py-12 text-base-content/50">
            <.icon name="hero-credit-card" class="size-12 mx-auto mb-3 opacity-30" />
            <p>Nenhum cartão cadastrado.</p>
            <button phx-click="new" class="btn btn-primary btn-sm mt-3">Adicionar cartão</button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp format_currency(amount) when is_nil(amount), do: "R$ 0,00"
  defp format_currency(amount) do
    value = Decimal.to_float(amount)
    formatted = :erlang.float_to_binary(value, decimals: 2)
    [integer_part, decimal_part] = String.split(formatted, ".")
    integer_with_sep = integer_part |> String.graphemes() |> Enum.reverse() |> Enum.chunk_every(3) |> Enum.join(".") |> String.graphemes() |> Enum.reverse() |> Enum.join()
    "R$ #{integer_with_sep},#{decimal_part}"
  end
end
