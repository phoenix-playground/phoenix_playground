#!/usr/bin/env elixir
Mix.install([
  {:phoenix_playground, "~> 0.1.0"}
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
    <span><%= @count %></span>
    <button onclick={"window.location.href='/?count=#{@count + 1}'"}>+</button>
    <button onclick={"window.location.href='/?count=#{@count - 1}'"}>-</button>

    <p>Now edit <code><%= __ENV__.file %>:<%= __ENV__.line %></code> in your editor...</p>

    <style type="text/css">
      body { padding: 1em; }
      span { font-family: monospace; }
      p { margin-top: 1em; }
    </style>
    """
  end
end

{:ok, _} = PhoenixPlayground.start_link(controller: DemoController)
Process.sleep(:infinity)
