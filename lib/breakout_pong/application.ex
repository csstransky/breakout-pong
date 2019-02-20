defmodule BreakoutPong.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      BreakoutPongWeb.Endpoint,
      # Starts a worker by calling: BreakoutPong.Worker.start_link(arg)
      # {BreakoutPong.Worker, arg},

      BreakoutPong.GameSup,
      BreakoutPong.BackupAgent,
      BreakoutPong.GameSup.reg(Registry, [:unique, :game_names])

    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BreakoutPong.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BreakoutPongWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
