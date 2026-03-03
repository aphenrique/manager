defmodule ManagerWeb.TransactionsLive.New do
  use ManagerWeb, :live_view

  alias Manager.Finance.{Transactions, Transaction, Accounts, CreditCards, Categories}

  @impl true
  def mount(_params, _session, socket) do
    changeset = Transactions.change_transaction(%Transaction{})
    accounts = Accounts.list_accounts()
    credit_cards = CreditCards.list_credit_cards()
    categories = Categories.list_categories()

    {:ok,
     socket
     |> assign(:page_title, "Nova Transação")
     |> assign(:form, to_form(changeset))
     |> assign(:accounts, accounts)
     |> assign(:credit_cards, credit_cards)
     |> assign(:categories, categories)
     |> assign(:destination_type, "account")}
  end

  @impl true
  def handle_event("destination-type", %{"type" => type}, socket) do
    {:noreply, assign(socket, :destination_type, type)}
  end

  def handle_event("save", %{"transaction" => params}, socket) do
    case Transactions.create_transaction(params) do
      {:ok, _transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transação lançada com sucesso!")
         |> push_navigate(to: ~p"/transactions")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-lg mx-auto space-y-6">
      <div class="flex items-center gap-3">
        <.link href={~p"/transactions"} class="btn btn-ghost btn-sm gap-1">
          <.icon name="hero-arrow-left" class="size-4" />
          Transações
        </.link>
        <h1 class="text-2xl font-bold text-base-content">Nova Transação</h1>
      </div>

      <div class="card bg-base-200 border border-base-300">
        <div class="card-body p-4">
          <.form for={@form} phx-submit="save" class="space-y-4">
            <div>
              <.input field={@form[:type]} type="select" label="Tipo"
                options={[{"Despesa", "expense"}, {"Receita", "income"}, {"Transferência", "transfer"}]} />
            </div>

            <div>
              <.input field={@form[:description]} label="Descrição" placeholder="Ex: Almoço, Mercado, Salário..." />
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <.input field={@form[:amount]} type="number" label="Valor (R$)" step="0.01" placeholder="0,00" />
              </div>
              <div>
                <.input field={@form[:date]} type="date" label="Data" value={Date.utc_today()} />
              </div>
            </div>

            <%!-- Destination: account or credit card --%>
            <div>
              <label class="label"><span class="label-text text-base-content/70">Lançar em</span></label>
              <div class="flex gap-2 mb-2">
                <button type="button" phx-click="destination-type" phx-value-type="account"
                  class={["btn btn-sm flex-1", if(@destination_type == "account", do: "btn-primary", else: "btn-ghost")]}>
                  Conta
                </button>
                <button type="button" phx-click="destination-type" phx-value-type="credit_card"
                  class={["btn btn-sm flex-1", if(@destination_type == "credit_card", do: "btn-primary", else: "btn-ghost")]}>
                  Cartão
                </button>
              </div>

              <%= if @destination_type == "account" do %>
                <.input field={@form[:account_id]} type="select" label=""
                  options={[{"— Selecione uma conta —", nil}] ++ Enum.map(@accounts, &{&1.name, &1.id})} />
              <% else %>
                <.input field={@form[:credit_card_id]} type="select" label=""
                  options={[{"— Selecione um cartão —", nil}] ++ Enum.map(@credit_cards, &{&1.name, &1.id})} />
              <% end %>
            </div>

            <div>
              <.input field={@form[:category_id]} type="select" label="Categoria (opcional)"
                options={[{"— Sem categoria —", nil}] ++ Enum.map(@categories, &{&1.name, &1.id})} />
            </div>

            <div>
              <.input field={@form[:notes]} label="Observações (opcional)" placeholder="Detalhes adicionais..." />
            </div>

            <div class="flex gap-2 justify-end pt-2">
              <.link href={~p"/transactions"} class="btn btn-ghost btn-sm">Cancelar</.link>
              <button type="submit" class="btn btn-primary btn-sm">Salvar Transação</button>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end
end
