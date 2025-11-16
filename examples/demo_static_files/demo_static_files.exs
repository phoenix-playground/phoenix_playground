Mix.install([
  # TODO: Update when stable/released?
  # {:phoenix_playground, "~> 0.1.9"}
  {:phoenix_playground, path: Path.expand("../..", __DIR__)}
])

defmodule DemoStatic do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~H"""
    <span>{@count}</span>
    <button phx-click="inc">
      <img src="/assets/inc.svg" alt="increment"/>
    </button>

    <style type="text/css">
      @import url("/assets/style.css");
    </style>
    """
  end

  def handle_event("inc", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end
end

defmodule DemoPlug do
  use Plug.Builder

  plug Plug.Static, at: "/assets", from: Path.expand("assets", __DIR__)
end

PhoenixPlayground.start(
  live: DemoStatic,
  plug: DemoPlug
)
