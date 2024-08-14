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
  plug :run_live_reload

  # TODO:
  # plug Phoenix.Ecto.CheckRepoStatus, otp_app: :phoenix_playground

  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.Session, @session_options
  plug PhoenixPlayground.Router

  defp run_live_reload(conn, _options) do
    if Application.get_env(:phoenix_playground, :live_reload) do
      conn
      |> Phoenix.LiveReloader.call([])
      |> Phoenix.CodeReloader.call(reloader: &PhoenixPlayground.CodeReloader.reload/2)
    else
      conn
    end
  end

  # See https://github.com/phoenixframework/phoenix/blob/v1.7.14/lib/phoenix/endpoint.ex#L484:L490
  @plug_debugger [
    banner: {Phoenix.Endpoint.RenderErrors, :__debugger_banner__, []},
    style: [
      primary: "#EB532D",
      logo:
        "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgNzEgNDgiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiPgoJPHBhdGggZD0ibTI2LjM3MSAzMy40NzctLjU1Mi0uMWMtMy45Mi0uNzI5LTYuMzk3LTMuMS03LjU3LTYuODI5LS43MzMtMi4zMjQuNTk3LTQuMDM1IDMuMDM1LTQuMTQ4IDEuOTk1LS4wOTIgMy4zNjIgMS4wNTUgNC41NyAyLjM5IDEuNTU3IDEuNzIgMi45ODQgMy41NTggNC41MTQgNS4zMDUgMi4yMDIgMi41MTUgNC43OTcgNC4xMzQgOC4zNDcgMy42MzQgMy4xODMtLjQ0OCA1Ljk1OC0xLjcyNSA4LjM3MS0zLjgyOC4zNjMtLjMxNi43NjEtLjU5MiAxLjE0NC0uODg2bC0uMjQxLS4yODRjLTIuMDI3LjYzLTQuMDkzLjg0MS02LjIwNS43MzUtMy4xOTUtLjE2LTYuMjQtLjgyOC04Ljk2NC0yLjU4Mi0yLjQ4Ni0xLjYwMS00LjMxOS0zLjc0Ni01LjE5LTYuNjExLS43MDQtMi4zMTUuNzM2LTMuOTM0IDMuMTM1LTMuNi45NDguMTMzIDEuNzQ2LjU2IDIuNDYzIDEuMTY1LjU4My40OTMgMS4xNDMgMS4wMTUgMS43MzggMS40OTMgMi44IDIuMjUgNi43MTIgMi4zNzUgMTAuMjY1LS4wNjgtNS44NDItLjAyNi05LjgxNy0zLjI0LTEzLjMwOC03LjMxMy0xLjM2Ni0xLjU5NC0yLjctMy4yMTYtNC4wOTUtNC43ODUtMi42OTgtMy4wMzYtNS42OTItNS43MS05Ljc5LTYuNjIzQzEyLjgtLjYyMyA3Ljc0NS4xNCAyLjg5MyAyLjM2MSAxLjkyNiAyLjgwNC45OTcgMy4zMTkgMCA0LjE0OWMuNDk0IDAgLjc2My4wMDYgMS4wMzIgMCAyLjQ0Ni0uMDY0IDQuMjggMS4wMjMgNS42MDIgMy4wMjQuOTYyIDEuNDU3IDEuNDE1IDMuMTA0IDEuNzYxIDQuNzk4LjUxMyAyLjUxNS4yNDcgNS4wNzguNTQ0IDcuNjA1Ljc2MSA2LjQ5NCA0LjA4IDExLjAyNiAxMC4yNiAxMy4zNDYgMi4yNjcuODUyIDQuNTkxIDEuMTM1IDcuMTcyLjU1NVpNMTAuNzUxIDMuODUyYy0uOTc2LjI0Ni0xLjc1Ni0uMTQ4LTIuNTYtLjk2MiAxLjM3Ny0uMzQzIDIuNTkyLS40NzYgMy44OTctLjUyOC0uMTA3Ljg0OC0uNjA3IDEuMzA2LTEuMzM2IDEuNDlabTMyLjAwMiAzNy45MjRjLS4wODUtLjYyNi0uNjItLjkwMS0xLjA0LTEuMjI4LTEuODU3LTEuNDQ2LTQuMDMtMS45NTgtNi4zMzMtMi0xLjM3NS0uMDI2LTIuNzM1LS4xMjgtNC4wMzEtLjYxLS41OTUtLjIyLTEuMjYtLjUwNS0xLjI0NC0xLjI3Mi4wMTUtLjc4LjY5My0xIDEuMzEtMS4xODQuNTA1LS4xNSAxLjAyNi0uMjQ3IDEuNi0uMzgyLTEuNDYtLjkzNi0yLjg4Ni0xLjA2NS00Ljc4Ny0uMy0yLjk5MyAxLjIwMi01Ljk0MyAxLjA2LTguOTI2LS4wMTctMS42ODQtLjYwOC0zLjE3OS0xLjU2My00LjczNS0yLjQwOGwtLjA0My4wM2EyLjk2IDIuOTYgMCAwIDAgLjA0LS4wMjljLS4wMzgtLjExNy0uMTA3LS4xMi0uMTk3LS4wNTRsLjEyMi4xMDdjMS4yOSAyLjExNSAzLjAzNCAzLjgxNyA1LjAwNCA1LjI3MSAzLjc5MyAyLjggNy45MzYgNC40NzEgMTIuNzg0IDMuNzNBNjYuNzE0IDY2LjcxNCAwIDAgMSAzNyA0MC44NzdjMS45OC0uMTYgMy44NjYuMzk4IDUuNzUzLjg5OVptLTkuMTQtMzAuMzQ1Yy0uMTA1LS4wNzYtLjIwNi0uMjY2LS40Mi0uMDY5IDEuNzQ1IDIuMzYgMy45ODUgNC4wOTggNi42ODMgNS4xOTMgNC4zNTQgMS43NjcgOC43NzMgMi4wNyAxMy4yOTMuNTEgMy41MS0xLjIxIDYuMDMzLS4wMjggNy4zNDMgMy4zOC4xOS0zLjk1NS0yLjEzNy02LjgzNy01Ljg0My03LjQwMS0yLjA4NC0uMzE4LTQuMDEuMzczLTUuOTYyLjk0LTUuNDM0IDEuNTc1LTEwLjQ4NS43OTgtMTUuMDk0LTIuNTUzWm0yNy4wODUgMTUuNDI1Yy43MDguMDU5IDEuNDE2LjEyMyAyLjEyNC4xODUtMS42LTEuNDA1LTMuNTUtMS41MTctNS41MjMtMS40MDQtMy4wMDMuMTctNS4xNjcgMS45MDMtNy4xNCAzLjk3Mi0xLjczOSAxLjgyNC0zLjMxIDMuODctNS45MDMgNC42MDQuMDQzLjA3OC4wNTQuMTE3LjA2Ni4xMTcuMzUuMDA1LjY5OS4wMjEgMS4wNDcuMDA1IDMuNzY4LS4xNyA3LjMxNy0uOTY1IDEwLjE0LTMuNy44OS0uODYgMS42ODUtMS44MTcgMi41NDQtMi43MS43MTYtLjc0NiAxLjU4NC0xLjE1OSAyLjY0NS0xLjA3Wm0tOC43NTMtNC42N2MtMi44MTIuMjQ2LTUuMjU0IDEuNDA5LTcuNTQ4IDIuOTQzLTEuNzY2IDEuMTgtMy42NTQgMS43MzgtNS43NzYgMS4zNy0uMzc0LS4wNjYtLjc1LS4xMTQtMS4xMjQtLjE3bC0uMDEzLjE1NmMuMTM1LjA3LjI2NS4xNTEuNDA1LjIwNy4zNTQuMTQuNzAyLjMwOCAxLjA3LjM5NSA0LjA4My45NzEgNy45OTIuNDc0IDExLjUxNi0xLjgwMyAyLjIyMS0xLjQzNSA0LjUyMS0xLjcwNyA3LjAxMy0xLjMzNi4yNTIuMDM4LjUwMy4wODMuNzU2LjEwNy4yMzQuMDIyLjQ3OS4yNTUuNzk1LjAwMy0yLjE3OS0xLjU3NC00LjUyNi0yLjA5Ni03LjA5NC0xLjg3MlptLTEwLjA0OS05LjU0NGMxLjQ3NS4wNTEgMi45NDMtLjE0MiA0LjQ4Ni0xLjA1OS0uNDUyLjA0LS42NDMuMDQtLjgyNy4wNzYtMi4xMjYuNDI0LTQuMDMzLS4wNC01LjczMy0xLjM4My0uNjIzLS40OTMtMS4yNTctLjk3NC0xLjg4OS0xLjQ1Ny0yLjUwMy0xLjkxNC01LjM3NC0yLjU1NS04LjUxNC0yLjUuMDUuMTU0LjA1NC4yNi4xMDguMzE1IDMuNDE3IDMuNDU1IDcuMzcxIDUuODM2IDEyLjM2OSA2LjAwOFptMjQuNzI3IDE3LjczMWMtMi4xMTQtMi4wOTctNC45NTItMi4zNjctNy41NzgtLjUzNyAxLjczOC4wNzggMy4wNDMuNjMyIDQuMTAxIDEuNzI4LjM3NC4zODguNzYzLjc2OCAxLjE4MiAxLjEwNiAxLjYgMS4yOSA0LjMxMSAxLjM1MiA1Ljg5Ni4xNTUtMS44NjEtLjcyNi0xLjg2MS0uNzI2LTMuNjAxLTIuNDUyWm0tMjEuMDU4IDE2LjA2Yy0xLjg1OC0zLjQ2LTQuOTgxLTQuMjQtOC41OS00LjAwOGE5LjY2NyA5LjY2NyAwIDAgMSAyLjk3NyAxLjM5Yy44NC41ODYgMS41NDcgMS4zMTEgMi4yNDMgMi4wNTUgMS4zOCAxLjQ3MyAzLjUzNCAyLjM3NiA0Ljk2MiAyLjA3LS42NTYtLjQxMi0xLjIzOC0uODQ4LTEuNTkyLTEuNTA3Wm0xNy4yOS0xOS4zMmMwLS4wMjMuMDAxLS4wNDUuMDAzLS4wNjhsLS4wMDYuMDA2LjAwNi0uMDA2LS4wMzYtLjAwNC4wMjEuMDE4LjAxMi4wNTNabS0yMCAxNC43NDRhNy42MSA3LjYxIDAgMCAwLS4wNzItLjA0MS4xMjcuMTI3IDAgMCAwIC4wMTUuMDQzYy4wMDUuMDA4LjAzOCAwIC4wNTgtLjAwMlptLS4wNzItLjA0MS0uMDA4LS4wMzQtLjAwOC4wMS4wMDgtLjAxLS4wMjItLjAwNi4wMDUuMDI2LjAyNC4wMTRaIgogICAgICAgICAgICBmaWxsPSIjRkQ0RjAwIiAvPgo8L3N2Zz4K"
    ]
  ]

  # See https://github.com/elixir-plug/plug/blob/v1.16.1/lib/plug/debugger.ex#L129:L146
  def call(conn, opts) do
    if Application.get_env(:phoenix_playground, :debug_errors, false) do
      try do
        case conn do
          %Plug.Conn{path_info: ["__plug__", "debugger", "action"], method: "POST"} ->
            Plug.Debugger.run_action(conn)

          %Plug.Conn{} ->
            super(conn, opts)
        end
      rescue
        e in Plug.Conn.WrapperError ->
          %{conn: conn, kind: kind, reason: reason, stack: stack} = e
          Plug.Debugger.__catch__(conn, kind, reason, stack, @plug_debugger)
      catch
        kind, reason ->
          Plug.Debugger.__catch__(conn, kind, reason, __STACKTRACE__, @plug_debugger)
      end
    else
      super(conn, opts)
    end
  end
end
