defmodule ManagerWeb.PageController do
  use ManagerWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.

    if conn.assigns.current_user do
      redirect(conn, to: ~p"/transactions")
    else
      redirect(conn, to: ~p"/users/log_in")
    end

    # render(conn, :home, layout: false)
  end
end
