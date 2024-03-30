#!/usr/bin/env elixir
Mix.install([
  {:phoenix_playground, github: "phoenix-playground/phoenix_playground"}
  # TODO:
  # {:phoenix_playground, "~> 0.1.0"}
])

defmodule DemoController do
  use Phoenix.Controller, formats: [:html]
  use Phoenix.Component
  plug :put_layout, false
  plug :put_view, __MODULE__

  def index(conn, params) do
    count =
      case Integer.parse(params["count"] || "") do
        {n, ""} -> n
        _ -> 0
      end

    render(conn, :index, count: count)
  end

  def index(assigns) do
    ~H"""
    <div style="padding: 1em;">
      <span style="font-family: monospace;"><%= @count %></span>
      <button onclick={"window.location.href='/?count=#{@count + 1}'"}>+</button>
      <button onclick={"window.location.href='/?count=#{@count - 1}'"}>-</button>

      <p style="margin-top: 1em;">Now edit <code><%= __ENV__.file %>:<%= __ENV__.line %></code> in your editor...</p>
    </div>
    """
  end
end

{:ok, _} = PhoenixPlayground.start_link(controller: DemoController)
Process.sleep(:infinity)
