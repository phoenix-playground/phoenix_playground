#!/usr/bin/env elixir
Mix.install([
  {:phoenix_playground, "~> 0.1.0"}
])

defmodule CounterLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~H"""
    <div style="padding: 1em;">
      <span style="font-family: monospace;"><%= @count %></span>
      <button phx-click="inc">+</button>
      <button phx-click="dec">-</button>

      <p style="margin-top: 1em;">Now edit <code><%= __ENV__.file %>:<%= __ENV__.line %></code> in your editor...</p>
    </div>
    """
  end

  def handle_event("inc", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  def handle_event("dec", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count - 1)}
  end
end

defmodule ClockLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, :tick)
    end

    {:ok, assign(socket, now: now())}
  end

  def render(assigns) do
    ~H"""
    <div style="padding: 1em;">
      <span style="font-family: monospace;"><%= @now %></span>

      <p style="margin-top: 1em;">Now edit <code><%= __ENV__.file %>:<%= __ENV__.line %></code> in your editor...</p>
    </div>
    """
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, now: now())}
  end

  defp now do
    to_string(NaiveDateTime.local_now())
  end
end

defmodule Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :put_root_layout, html: {PhoenixPlayground.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/" do
    pipe_through :browser

    live_session :default, layout: {PhoenixPlayground.Layouts, :live} do
      live "/", CounterLive, :index
      live "/clock", ClockLive, :index
    end
  end
end

{:ok, _} = PhoenixPlayground.start_link(router: Router)
