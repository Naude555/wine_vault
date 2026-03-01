defmodule WineVault.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WineVaultWeb.Telemetry,
      WineVault.Repo,
      {DNSCluster, query: Application.get_env(:wine_vault, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WineVault.PubSub},
      # Start a worker by calling: WineVault.Worker.start_link(arg)
      # {WineVault.Worker, arg},
      # Start to serve requests, typically the last entry
      WineVaultWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WineVault.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WineVaultWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
