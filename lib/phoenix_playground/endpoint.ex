Application.put_env(:phoenix_playground, PhoenixPlayground.Endpoint, debug_errors: true)

defmodule PhoenixPlayground.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :phoenix_playground

  @signing_salt "ll+Leuc4"

  @session_options [
    store: :cookie,
    key: "_phoenix_playground_key",
    signing_salt: @signing_salt,
    same_site: "Lax",
    # 14 days
    max_age: 14 * 24 * 60 * 60
  ]

  socket "/live", Phoenix.LiveView.Socket

  plug Plug.Static, from: {:phoenix, "priv/static"}, at: "/assets/phoenix"
  plug Plug.Static, from: {:phoenix_live_view, "priv/static"}, at: "/assets/phoenix_live_view"

  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
  plug Phoenix.LiveReloader
  plug Phoenix.CodeReloader, reloader: &PhoenixPlayground.CodeReloader.reload/2
  # TODO:
  # plug Phoenix.Ecto.CheckRepoStatus, otp_app: :phoenix_playground

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.Session, @session_options
  plug PhoenixPlayground.Router
end
