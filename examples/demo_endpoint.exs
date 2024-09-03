#!/usr/bin/env elixir
Mix.install([
  {:phoenix_playground, "~> 0.1.6"}
])

defmodule DemoLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~H"""
    <script>
      let liveSocket = new window.LiveView.LiveSocket("/live", window.Phoenix.Socket, {})
      liveSocket.connect()
    </script>

    <span>Count: <%= @count %></span>
    <button phx-click="inc">+</button>
    <button phx-click="dec">-</button>
    """
  end

  def handle_event("inc", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("dec", _params, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end
end

defmodule Demo.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :put_root_layout, html: {PhoenixPlayground.Layout, :root}
  end

  scope "/" do
    pipe_through :browser
    live "/", DemoLive
  end
end

defmodule Demo.Endpoint do
  use Phoenix.Endpoint, otp_app: :phoenix_playground
  plug Plug.Logger
  socket "/live", Phoenix.LiveView.Socket
  plug Plug.Static, from: {:phoenix, "priv/static"}, at: "/assets/phoenix"
  plug Plug.Static, from: {:phoenix_live_view, "priv/static"}, at: "/assets/phoenix_live_view"
  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
  plug Phoenix.LiveReloader
  plug Phoenix.CodeReloader, reloader: &PhoenixPlayground.CodeReloader.reload/2
  plug Demo.Router
end

PhoenixPlayground.start(endpoint: Demo.Endpoint)
