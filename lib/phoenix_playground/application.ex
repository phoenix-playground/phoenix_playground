defmodule PhoenixPlayground.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # suppress Phoenix warning about no endpoint configuration
    Application.put_env(:phoenix_playground, PhoenixPlayground.Endpoint, [])

    Application.put_env(:phoenix_live_view, :debug_heex_annotations, true)

    Supervisor.start_link([], strategy: :one_for_one, name: __MODULE__)
  end
end
