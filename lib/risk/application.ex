defmodule Risk.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: Risk.GameRegistry},
      Risk.GameSupervisor,
      # Start the Ecto repository
      Risk.Repo,
      # Start the endpoint when the application starts
      RiskWeb.Endpoint
      # Starts a worker by calling: Risk.Worker.start_link(arg)
      # {Risk.Worker, arg},
    ]

    :ets.new(:games_table, [:public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Risk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RiskWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
