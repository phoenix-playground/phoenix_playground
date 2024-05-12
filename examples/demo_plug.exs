#!/usr/bin/env elixir
Mix.install([
  {:phoenix_playground, "~> 0.1.2", github: "phoenix-playground/phoenix_playground"}
])

PhoenixPlayground.start(
  plug: fn conn ->
    Plug.Conn.send_resp(conn, 200, "Hello!")
  end
)
