defmodule ManagerWeb.CategoriesLive.Index do
  use ManagerWeb, :live_view

  alias Manager.Finance.{Categories, Category}

  @impl true
  def mount(_params, _session, socket) do
    categories = Categories.list_categories()
    {:ok,
     socket
     |> assign(:page_title, "Categorias")
     |> assign(:categories, categories)
     |> assign(:form, nil)}
  end

  @impl true
  def handle_event("new", _params, socket) do
    changeset = Categories.change_category(%Category{})
    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, :form, nil)}
  end

  def handle_event("save", %{"category" => params}, socket) do
    case Categories.create_category(params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Categoria criada!")
         |> assign(:categories, Categories.list_categories())
         |> assign(:form, nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    category = Categories.get_category!(id)
    {:ok, _} = Categories.delete_category(category)
    {:noreply,
     socket
     |> put_flash(:info, "Categoria removida.")
     |> assign(:categories, Categories.list_categories())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold text-base-content">Categorias</h1>
        <button phx-click="new" class="btn btn-primary btn-sm gap-2">
          <.icon name="hero-plus" class="size-4" />
          Nova Categoria
        </button>
      </div>

      <%= if @form do %>
        <div class="card bg-base-200 border border-base-300">
          <div class="card-body p-4">
            <h2 class="font-semibold text-base-content mb-4">Nova Categoria</h2>
            <.form for={@form} phx-submit="save" class="space-y-4">
              <div class="grid grid-cols-3 gap-4">
                <div class="col-span-2">
                  <.input field={@form[:name]} label="Nome" placeholder="Ex: Alimentação" />
                </div>
                <div>
                  <.input field={@form[:color]} type="color" label="Cor" value="#6366f1" />
                </div>
                <div>
                  <.input field={@form[:type]} type="select" label="Tipo"
                    options={[{"Despesa", "expense"}, {"Receita", "income"}, {"Ambos", "both"}]} />
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

      <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
        <%= for cat <- @categories do %>
          <div class="flex items-center justify-between p-3 bg-base-200 border border-base-300 rounded-lg">
            <div class="flex items-center gap-3">
              <div class="w-8 h-8 rounded-full flex items-center justify-center" style={"background-color: #{cat.color}30"}>
                <div class="w-3 h-3 rounded-full" style={"background-color: #{cat.color}"}></div>
              </div>
              <div>
                <p class="text-sm font-medium text-base-content">{cat.name}</p>
                <p class="text-xs text-base-content/50">{type_label(cat.type)}</p>
              </div>
            </div>
            <button phx-click="delete" phx-value-id={cat.id}
              class="btn btn-ghost btn-xs text-error"
              data-confirm={"Remover a categoria '#{cat.name}'?"}>
              <.icon name="hero-trash" class="size-3" />
            </button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp type_label("expense"), do: "Despesa"
  defp type_label("income"), do: "Receita"
  defp type_label("both"), do: "Despesa e Receita"
  defp type_label(_), do: ""
end
