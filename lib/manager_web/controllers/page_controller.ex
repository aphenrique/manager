defmodule ManagerWeb.PageController do
  use ManagerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
