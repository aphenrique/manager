# LiveView — Core, Streams e JS Interop

## Regras Gerais

- **Never** use deprecated `live_redirect` and `live_patch` — use `<.link navigate={href}>` and `<.link patch={href}>` in templates, and `push_navigate` / `push_patch` in LiveViews
- **Avoid LiveComponents** unless you have a strong, specific need
- LiveViews named like `AppWeb.WeatherLive` — the default `:browser` scope is already aliased with `AppWeb`, so just do `live "/weather", WeatherLive`

## Phoenix Router

- `scope` blocks include an optional alias prefixed for all routes within the scope — **always** be mindful of this to avoid duplicate module prefixes
- You **never** need to create your own `alias` for route definitions — the `scope` provides it:

      scope "/admin", AppWeb.Admin do
        pipe_through :browser
        live "/users", UserLive, :index  # → AppWeb.Admin.UserLive
      end

- `Phoenix.View` no longer exists in Phoenix — don't use it

## LiveView Streams

**Always** use streams for collections (not regular assigns) to avoid memory ballooning:

    stream(socket, :messages, [new_msg])                         # append
    stream(socket, :messages, [new_msg], reset: true)            # reset
    stream(socket, :messages, [new_msg], at: -1)                 # prepend
    stream_delete(socket, :messages, msg)                        # delete

Template must have `phx-update="stream"` on parent, and consume `@streams.stream_name`:

    <div id="messages" phx-update="stream">
      <div :for={{id, msg} <- @streams.messages} id={id}>
        {msg.text}
      </div>
    </div>

- Streams are **not enumerable** — cannot use `Enum.filter/2`. To filter: refetch data and re-stream with `reset: true`
- Streams **do not support counting or empty states** — track count with a separate assign; for empty state use Tailwind `only:` variant:

      <div id="tasks" phx-update="stream">
        <div class="hidden only:block">No tasks yet</div>
        <div :for={{id, task} <- @streams.tasks} id={id}>{task.name}</div>
      </div>

- When updating an assign that affects content inside streamed items, **must re-stream** those items:

      {:noreply,
       socket
       |> stream_insert(:messages, message)
       |> assign(:editing_message_id, String.to_integer(message_id))}

- **Never** use deprecated `phx-update="append"` or `phx-update="prepend"`

## JavaScript Interop — phx-hook

- When a JS hook manages its own DOM, **must** also set `phx-update="ignore"`
- **Always** provide a unique DOM id alongside `phx-hook` (compiler error otherwise)

### Inline Colocated JS Hooks

**Never** write raw `<script>` tags in HEEx — always use colocated hook script tag:

    <input type="text" id="user-phone-number" phx-hook=".PhoneNumber" />
    <script :type={Phoenix.LiveView.ColocatedHook} name=".PhoneNumber">
      export default {
        mounted() {
          this.el.addEventListener("input", e => {
            let match = this.el.value.replace(/\D/g, "").match(/^(\d{3})(\d{3})(\d{4})$/)
            if(match) { this.el.value = `${match[1]}-${match[2]}-${match[3]}` }
          })
        }
      }
    </script>

- Colocated hooks are automatically integrated into the `app.js` bundle
- Colocated hook names **MUST** start with `.` prefix: `.PhoneNumber`

### External phx-hook

Place in `assets/js/` and pass to the `LiveSocket` constructor:

    const MyHook = { mounted() { ... } }
    let liveSocket = new LiveSocket("/live", Socket, { hooks: { MyHook } });

### Pushing Events

Use `push_event/3` to push events to the client:

    socket = push_event(socket, "my_event", %{...})

Pick up in a JS hook with `this.handleEvent`:

    mounted() {
      this.handleEvent("my_event", data => console.log("from server:", data));
    }

Client can push event to server and receive a reply with `this.pushEvent`:

    mounted() {
      this.el.addEventListener("click", e => {
        this.pushEvent("my_event", { one: 1 }, reply => console.log("reply:", reply));
      })
    }

Server handles it via:

    def handle_event("my_event", %{"one" => 1}, socket) do
      {:reply, %{two: 2}, socket}
    end
