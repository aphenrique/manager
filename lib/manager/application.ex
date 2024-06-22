defmodule Manager.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ManagerWeb.Telemetry,
      Manager.Repo,
      {DNSCluster, query: Application.get_env(:manager, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Manager.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Manager.Finch},
      # Start a worker by calling: Manager.Worker.start_link(arg)
      # {Manager.Worker, arg},
      # Start to serve requests, typically the last entry
      ManagerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Manager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
