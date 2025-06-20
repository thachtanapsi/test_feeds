defmodule TestFeeds.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # spamwer
      {Registry, keys: :unique, name: :my_registry},
      TenMilionSpamer.Supervisor,
      UdpSender,
      # Starts a worker by calling: TestFeeds.Worker.start_link(arg)
      # {TestFeeds.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TestFeeds.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
