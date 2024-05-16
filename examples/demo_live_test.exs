#!/usr/bin/env elixir
Mix.install([
  {:phoenix_playground, "~> 0.1.3"}
])

defmodule DemoLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~H"""
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
