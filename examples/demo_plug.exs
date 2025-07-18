#!/usr/bin/env elixir
Mix.install([
  {:phoenix_playground, "~> 0.1.7"}
])

PhoenixPlayground.start(
  plug: fn conn ->
    Plug.Conn.send_resp(conn, 200, "Hello!")
  end
)
