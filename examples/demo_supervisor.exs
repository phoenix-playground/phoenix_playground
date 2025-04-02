#!/usr/bin/env elixir
Mix.install([
  {:phoenix_playground, github: "phoenix-playground/phoenix_playground"}
])

plug = fn conn ->
  Plug.Conn.send_resp(conn, 200, "Hello!")
end

children = [
  {PhoenixPlayground, plug: plug, live_reload: false}
]

opts = [strategy: :one_for_one, name: __MODULE__]
Supervisor.start_link(children, opts)

