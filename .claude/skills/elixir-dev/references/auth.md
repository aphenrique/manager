# Authentication Guidelines (phx.gen.auth)

## Regras gerais

- **Always** handle authentication flow at the router level with proper redirects
- `phx.gen.auth` creates multiple router plugs:
  - `:fetch_current_scope_for_user` — included in default browser pipeline
  - `:require_authenticated_user` — redirects to log in when not authenticated
  - `redirect_if_user_is_authenticated` — redirects authenticated users (useful for registration page)
- In all cases, `@current_scope` is assigned to the Plug connection
- `phx.gen.auth` assigns `current_scope` — **does not assign** `current_user`
- Always pass `current_scope` to context modules as first argument
- When querying, use `current_scope.user` to filter results
- To access `current_user` in templates: **always use `@current_scope.user`**, never `@current_user`

## Rotas que requerem autenticação

Controller routes must be in a scope with `:require_authenticated_user`:

    scope "/", AppWeb do
      pipe_through [:browser, :require_authenticated_user]

      get "/", MyControllerThatRequiresAuth, :index
    end

## Rotas que funcionam com ou sem autenticação

Controllers automatically have `current_scope` available if they use the `:browser` pipeline.

## Debugging current_scope errors

Anytime you hit `current_scope` errors or the logged-in session shows wrong content:
- **Always double-check the router** — ensure you are using the correct plug as described above
- **Always let the user know** which router scopes and pipelines you are placing the route in, AND WHY
