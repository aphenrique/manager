# LiveView — Formulários

## Regras de Ouro

- **Always** use `Phoenix.Component.form/1` and `Phoenix.Component.inputs_for/1` — never `Phoenix.HTML.form_for` (outdated)
- **Always** use `to_form/2` in the LiveView: `assign(socket, form: to_form(...))`
- **Always** use `<.form for={@form} id="my-form">` in templates
- **Always** access form fields via `@form[:field]`
- **Always** give the form an explicit, unique DOM ID: `id="todo-form"`
- **You are FORBIDDEN** from accessing the changeset in the template — it will cause errors
- **Never** use `<.form let={f} ...>` — always `<.form for={@form} ...>`

## Criar formulário a partir de params

    def handle_event("submitted", params, socket) do
      {:noreply, assign(socket, form: to_form(params))}
    end

    # Com namespace:
    def handle_event("submitted", %{"user" => user_params}, socket) do
      {:noreply, assign(socket, form: to_form(user_params, as: :user))}
    end

## Criar formulário a partir de changesets

    %MyApp.Users.User{}
    |> Ecto.Changeset.change()
    |> to_form()
    # O :as é derivado automaticamente do schema

No template:

    <.form for={@form} id="user-form" phx-change="validate" phx-submit="save">
      <.input field={@form[:name]} type="text" />
    </.form>

Ao submeter, params chegam como `%{"user" => user_params}`.

## Exemplo correto vs incorreto

    <%!-- CORRETO --%>
    <.form for={@form} id="my-form">
      <.input field={@form[:field]} type="text" />
    </.form>

    <%!-- INCORRETO — nunca faça isso --%>
    <.form for={@changeset} id="my-form">
      <.input field={@changeset[:field]} type="text" />
    </.form>
