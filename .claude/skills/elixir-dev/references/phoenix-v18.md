# Phoenix v1.8 Guidelines

## Layouts e LiveView

- **Always** begin LiveView templates with `<Layouts.app flash={@flash} ...>` wrapping all inner content
- `MyAppWeb.Layouts` is aliased in `my_app_web.ex` — no need to alias again
- If you hit `no current_scope assign` errors:
  - You failed to follow Authenticated Routes guidelines, or forgot to pass `current_scope` to `<Layouts.app>`
  - Fix by moving routes to the proper `live_session` and passing `current_scope`
- Phoenix v1.8 moved `<.flash_group>` to the `Layouts` module — **forbidden** from calling it outside `layouts.ex`

## Componentes

- Use `<.icon name="hero-x-mark" class="w-5 h-5"/>` from `core_components.ex` — **always** use `<.icon>`, never `Heroicons` modules
- **Always** use the imported `<.input>` component from `core_components.ex` for form inputs
- If you override `<.input class="myclass ...">` with your own classes, no defaults are inherited — your classes must fully style the input

## Icon Coloring Pattern

The `<.icon>` component only accepts `name` and `class`. For dynamic colors, put `color: #{hex}` in the wrapping div's `style` (not on the icon). The icon inherits via CSS `currentColor`.
