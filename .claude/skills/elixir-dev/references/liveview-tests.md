# LiveView — Testes

## Setup

- Use `Phoenix.LiveViewTest` module and `LazyHTML` (included) for assertions
- Form tests: `render_submit/2` and `render_change/2`

## Estratégia

- Come up with a step-by-step test plan splitting major test cases into small, isolated files
- Start with simpler tests (content exists), gradually add interaction tests

## Assertions

- **Always reference key element IDs** added in the LiveView templates
- **Never** test against raw HTML — **always** use `element/2`, `has_element/2`, and similar:

      assert has_element?(view, "#my-form")

- Instead of relying on text content (which can change), favor testing for presence of key elements
- Focus on testing outcomes rather than implementation details
- Be aware that `Phoenix.Component` functions like `<.form>` may produce different HTML than expected — test against actual output, not mental model

## Debugging selectors

    html = render(view)
    document = LazyHTML.from_fragment(html)
    matches = LazyHTML.filter(document, "your-complex-selector")
    IO.inspect(matches, label: "Matches")

## HEEx Reference (evitar erros em templates)

- Templates use `~H` or `.html.heex` — **never** `~E`
- Elixir supports `if/else` but **NOT** `if/else if` — use `cond` or `case`
- HEEx class attrs must use list `[...]` syntax for multiple values:

      <a class={[
        "px-2 text-white",
        @some_flag && "py-5",
        if(@other_condition, do: "border-red-500", else: "border-blue-100"),
      ]}>

- HEEx HTML comments: `<%!-- comment --%>`
- Interpolation: `{...}` in attributes and values; `<%= ... %>` for block constructs in tag bodies
- Literal `{` and `}` in `<pre>`/`<code>` blocks: use `phx-no-curly-interpolation` on the parent tag
- **Never** use `<% Enum.each %>` — always `<%= for item <- @collection do %>`
