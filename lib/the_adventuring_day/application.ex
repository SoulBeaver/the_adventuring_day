defmodule TheAdventuringDay.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TheAdventuringDayWeb.Telemetry,
      # Start the Ecto repository
      TheAdventuringDay.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: TheAdventuringDay.PubSub},
      # Start Finch
      {Finch, name: TheAdventuringDay.Finch},
      # Start the Endpoint (http/https)
      TheAdventuringDayWeb.Endpoint,
      # Start a worker by calling: TheAdventuringDay.Worker.start_link(arg)
      # {TheAdventuringDay.Worker, arg}
      {Registry, [name: TheAdventuringDay.Registry.StoryWorkshop, keys: :unique]},
      {DynamicSupervisor, [name: TheAdventuringDay.Supervisor.StoryWorkshop, strategy: :one_for_one]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TheAdventuringDay.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TheAdventuringDayWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
