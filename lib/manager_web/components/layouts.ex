defmodule ManagerWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use ManagerWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  def app(assigns) do
    ~H"""
    <div class="flex h-screen overflow-hidden">
      <%!-- Sidebar --%>
      <aside class="w-64 flex-shrink-0 bg-base-200 border-r border-base-300 flex flex-col">
        <%!-- Logo --%>
        <div class="p-4 border-b border-base-300">
          <a href={~p"/"} class="flex items-center gap-2">
            <div class="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
              <.icon name="hero-banknotes" class="size-5 text-primary-content" />
            </div>
            <span class="font-bold text-lg text-base-content">Financeiro</span>
          </a>
        </div>

        <%!-- Navigation --%>
        <nav class="flex-1 p-3 space-y-1 overflow-y-auto">
          <.nav_item icon="hero-home" href={~p"/"} label="Dashboard" />
          <.nav_item icon="hero-building-library" href={~p"/accounts"} label="Contas" />
          <.nav_item icon="hero-credit-card" href={~p"/credit-cards"} label="Cartões" />
          <.nav_item icon="hero-arrow-up-down" href={~p"/transactions"} label="Transações" />
          <.nav_item icon="hero-tag" href={~p"/categories"} label="Categorias" />
          <.nav_item icon="hero-chart-bar" href={~p"/reports"} label="Relatórios" />
        </nav>

        <%!-- User area --%>
        <div class="p-3 border-t border-base-300">
          <%= if @current_scope do %>
            <div class="flex items-center gap-2 mb-2 px-2">
              <div class="w-7 h-7 bg-neutral rounded-full flex items-center justify-center">
                <.icon name="hero-user-mini" class="size-4 text-neutral-content" />
              </div>
              <span class="text-xs text-base-content truncate flex-1">{@current_scope.user.email}</span>
            </div>
            <.link
              href={~p"/users/log-out"}
              method="delete"
              class="btn btn-ghost btn-sm w-full justify-start gap-2 text-base-content/70"
            >
              <.icon name="hero-arrow-right-on-rectangle" class="size-4" />
              Sair
            </.link>
          <% end %>
        </div>
      </aside>

      <%!-- Main content --%>
      <main class="flex-1 overflow-y-auto bg-base-100">
        <.flash_group flash={@flash} />
        <div class="p-6">
          <%= if Map.has_key?(assigns, :inner_block), do: render_slot(@inner_block) %>
        </div>
      </main>
    </div>
    """
  end

  attr :icon, :string, required: true
  attr :href, :string, required: true
  attr :label, :string, required: true

  defp nav_item(assigns) do
    ~H"""
    <.link
      href={@href}
      class="flex items-center gap-3 px-3 py-2 rounded-lg text-base-content/70 hover:text-base-content hover:bg-base-300 transition-colors text-sm font-medium"
    >
      <.icon name={@icon} class="size-4 flex-shrink-0" />
      {@label}
    </.link>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
