#!/usr/bin/env elixir
Mix.install([
  {:phoenix_playground, path: "#{__DIR__}/.."}
  # TODO:
  # {:phoenix_playground, "~> 0.1.0"}
])

defmodule DemoLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~H"""
    <div style="padding: 1em;">
      <span style="font-family: monospace;">Count: <%= @count %></span>
      <button phx-click="inc">+</button>
      <button phx-click="dec">-</button>

      <p style="margin-top: 1em;">Now edit <code><%= __ENV__.file %></code> in your editor...</p>
    </div>
    """
  end

  def handle_event("inc", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("dec", _params, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end
end

Logger.configure(level: :info)
ExUnit.start()

defmodule DemoLiveTest do
  use ExUnit.Case
  use PhoenixPlayground.Test, live: DemoLive

  test "it works" do
    {:ok, view, html} = live(build_conn(), "/")

    assert html =~ "Count: 0"
    assert render_click(view, :inc, %{}) =~ "Count: 1"
    assert render_click(view, :inc, %{}) =~ "Count: 2"
  end
end
