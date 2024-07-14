#!/usr/bin/env elixir
Mix.install([
  {:phoenix_playground, path: Path.expand("..", __DIR__)}
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
    <button onclick={"window.location.href=\"/?count=#{@count + 1}\""}>+</button>
    <button onclick={"window.location.href=\"/?count=#{@count - 1}\""}>-</button>

    <style type="text/css">
      body { padding: 1em; }
    </style>
    """
  end
end

PhoenixPlayground.start(
  controller: DemoController,
  endpoint_options: [
    secret_key_base: "b8X+FHhV/h4N3mFRcwtGmKmTIJkl7acxJyTujEWevtfmH7T+v3P9tb+H+K1JpJlj"
  ]
)
