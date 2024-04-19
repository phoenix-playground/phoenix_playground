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
    <span>Count: <%= @count %></span>
    <button onclick={"window.location.href='/?count=#{@count + 1}'"}>+</button>
    <button onclick={"window.location.href='/?count=#{@count - 1}'"}>-</button>
    """
  end
end

Logger.configure(level: :info)
ExUnit.start()

defmodule DemoControllerTest do
  use ExUnit.Case
  use PhoenixPlayground.Test, controller: DemoController

  test "it works" do
    conn = get(build_conn(), "/")
    assert html_response(conn, 200) =~ "Count: 0"

    conn = get(build_conn(), "/?count=1")
    assert html_response(conn, 200) =~ "Count: 1"
  end
end
