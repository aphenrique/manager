defmodule ManagerWeb.CoreComponents do
  @moduledoc """
  Fornece componentes de UI principais.

  À primeira vista, este módulo pode parecer intimidador, mas seu objetivo é fornecer
  blocos de construção fundamentais para sua aplicação, como modais, tabelas e
  formulários. Os componentes consistem principalmente de marcação e são bem documentados
  com strings de documentação e atributos declarativos. Você pode personalizá-los e estilizá-los
  de qualquer maneira que desejar, com base no crescimento e nas necessidades da sua aplicação.

  Os componentes padrão usam Tailwind CSS, um framework CSS utilitário.
  Veja a [documentação do Tailwind CSS](https://tailwindcss.com) para aprender
  como personalizá-los ou sinta-se à vontade para trocar por outro framework completamente.

  Ícones são fornecidos por [heroicons](https://heroicons.com). Veja `icon/1` para uso.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import ManagerWeb.Gettext

  @doc """
  Renderiza um modal.

  ## Exemplos

      <.modal id="confirmar-modal">
        Isto é um modal.
      </.modal>

  Comandos JS podem ser passados para `:on_cancel` para configurar
  o evento de fechamento/cancelamento, por exemplo:

      <.modal id="confirmar" on_cancel={JS.navigate(~p"/posts")}>
        Este é outro modal.
      </.modal>

  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="bg-zinc-50/90 fixed inset-0 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="shadow-zinc-700/10 ring-zinc-700/10 relative hidden rounded-2xl bg-white p-14 shadow-lg ring-1 transition"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
                  aria-label={gettext("fechar")}
                >
                  <.icon name="hero-x-mark-solid" class="h-5 w-5" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                <%= render_slot(@inner_block) %>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renderiza avisos flash.

  ## Exemplos

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Bem-vindo de volta!</.flash>
  """
  attr :id, :string, doc: "o id opcional do contêiner flash"
  attr :flash, :map, default: %{}, doc: "o mapa de mensagens flash para exibir"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "usado para estilização e busca de flash"
  attr :rest, :global, doc: "os atributos HTML arbitrários para adicionar ao contêiner flash"

  slot :inner_block, doc: "o bloco interno opcional que renderiza a mensagem flash"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed top-2 right-2 mr-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4" />
        <%= @title %>
      </p>
      <p class="mt-2 text-sm leading-5"><%= msg %></p>
      <button type="button" class="group absolute top-1 right-1 p-2" aria-label={gettext("fechar")}>
        <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Mostra o grupo flash com títulos e conteúdo padrão.

  ## Exemplos

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "o mapa de mensagens flash"
  attr :id, :string, default: "flash-group", doc: "o id opcional do contêiner flash"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title={gettext("Sucesso!")} flash={@flash} />
      <.flash kind={:error} title={gettext("Erro!")} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("Não conseguimos encontrar a internet")}
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        <%= gettext("Tentando reconectar") %>
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Algo deu errado!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        <%= gettext("Aguente firme enquanto voltamos aos trilhos") %>
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Renderiza um formulário simples.

  ## Exemplos

      <.simple_form for={@form} phx-change="validar" phx-submit="salvar">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Nome de usuário" />
        <:actions>
          <.button>Salvar</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "a estrutura de dados para o formulário"

  attr :as, :any,
    default: nil,
    doc: "o parâmetro do lado do servidor para coletar todas as entradas"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "os atributos HTML arbitrários para aplicar à tag do formulário"

  slot :inner_block, required: true
  slot :actions, doc: "o slot para ações do formulário, como um botão de envio"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="mt-10 space-y-8 bg-gray-800 p-6 rounded-lg">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renderiza um botão.

  ## Exemplos

      <.button>Enviar!</.button>
      <.button phx-click="ir" class="ml-2">Enviar!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-indigo-600 hover:bg-indigo-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renderiza uma entrada com rótulo e mensagens de erro.

  Um `Phoenix.HTML.FormField` pode ser passado como argumento,
  que é usado para recuperar o nome, id e valores da entrada.
  Caso contrário, todos os atributos podem ser passados explicitamente.

  ## Tipos

  Esta função aceita todos os tipos de entrada HTML, considerando que:

    * Você também pode definir `type="select"` para renderizar uma tag `<select>`

    * `type="checkbox"` é usado exclusivamente para renderizar valores booleanos

    * Para uploads de arquivos ao vivo, veja `Phoenix.Component.live_file_input/1`

  Veja https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  para mais informações. Tipos não suportados, como hidden e radio,
  são melhor escritos diretamente em seus templates.

  ## Exemplos

      <.input field={@form[:email]} type="email" />
      <.input name="minha-entrada" errors={["oh não!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc:
      "uma estrutura de campo de formulário recuperada do formulário, por exemplo: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "a flag checked para entradas de checkbox"
  attr :prompt, :string, default: nil, doc: "o prompt para entradas select"
  attr :options, :list, doc: "as opções para passar para Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "a flag multiple para entradas select"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
          {@rest}
        />
        <%= @label %>
      </label>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div>
      <.label for={@id}><%= @label %></.label>
      <select
        id={@id}
        name={@name}
        class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 min-h-[6rem]",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  # Todas as outras entradas de texto, datetime-local, url, password, etc. são tratadas aqui...
  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "mt-2 block w-full rounded-lg text-gray-300 focus:ring-0 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-gray-700 phx-no-feedback:focus:border-indigo-500",
          "bg-gray-800 border-gray-700",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renderiza um rótulo.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Gera uma mensagem de erro genérica.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Renderiza um cabeçalho com título.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-gray-100">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-gray-400">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc ~S"""
  Renderiza uma tabela com estilo genérico.

  ## Exemplos

      <.table id="usuarios" rows={@usuarios}>
        <:col :let={usuario} label="id"><%= usuario.id %></:col>
        <:col :let={usuario} label="nome de usuário"><%= usuario.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "a função para gerar o id da linha"
  attr :row_click, :any, default: nil, doc: "a função para lidar com phx-click em cada linha"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "a função para mapear cada linha antes de chamar os slots :col e :action"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "o slot para mostrar ações do usuário na última coluna da tabela"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-y-auto px-4 sm:overflow-visible sm:px-0">
      <table class="w-[40rem] p-8 mt-11 sm:w-full bg-gray-800 text-gray-300">
        <thead class="text-sm text-left leading-6 text-gray-400">
          <tr>
            <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal"><%= col[:label] %></th>
            <th :if={@action != []} class="relative p-0 pb-4">
              <span class="sr-only"><%= gettext("Ações") %></span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative divide-y divide-gray-700 border-t border-gray-700 text-sm leading-6 text-gray-300"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-gray-700">
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["relative p-0", @row_click && "hover:cursor-pointer"]}
            >
              <div class="block py-4 pr-6">
                <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-gray-700 sm:rounded-l-xl" />
                <span class={["relative", i == 0 && "font-semibold text-gray-100"]}>
                  <%= render_slot(col, @row_item.(row)) %>
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative w-14 p-0">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-gray-700 sm:rounded-r-xl" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-gray-100 hover:text-gray-300"
                >
                  <%= render_slot(action, @row_item.(row)) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renderiza uma lista de dados.

  ## Exemplos

      <.list>
        <:item title="Título"><%= @post.title %></:item>
        <:item title="Visualizações"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14 p-8">
      <dl class="-my-4 p-8 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-zinc-500"><%= item.title %></dt>
          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renderiza um link de navegação para trás.

  ## Exemplos

      <.back navigate={~p"/posts"}>Voltar para posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Renderiza um [Heroicon](https://heroicons.com).

  Heroicons vêm em três estilos – outline, solid e mini.
  Por padrão, o estilo outline é usado, mas solid e mini podem
  ser aplicados usando os sufixos `-solid` e `-mini`.

  Você pode personalizar o tamanho e as cores dos ícones definindo
  largura, altura e cores de fundo.

  Ícones são extraídos do diretório `deps/heroicons` e embutidos dentro
  do seu arquivo compilado app.css pelo plugin em seu `assets/tailwind.config.js`.

  ## Exemplos

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      time: 300,
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Traduz uma mensagem de erro usando gettext.
  """
  def translate_error({msg, opts}) do
    # Quando usamos gettext, normalmente passamos as strings que queremos
    # traduzir como um argumento estático:
    #
    #     # Traduz o número de arquivos com regras de plural
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # No entanto, as mensagens de erro em nossos formulários e APIs são geradas
    # dinamicamente, então precisamos traduzi-las chamando Gettext
    # com nosso backend gettext como primeiro argumento. Traduções
    # estão disponíveis no arquivo errors.po (já que usamos o domínio "errors").
    if count = opts[:count] do
      Gettext.dngettext(ManagerWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(ManagerWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Traduz os erros de um campo de uma lista de chave-valor de erros.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
