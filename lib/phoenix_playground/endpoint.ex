defmodule PhoenixPlayground.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :phoenix_playground

  defoverridable start_link: 1

  @secret_key_base [
                     then(:inet.gethostname(), fn {:ok, host} -> host end),
                     System.get_env("USER", ""),
                     System.version(),
                     :erlang.system_info(:version),
                     :erlang.system_info(:system_architecture)
                   ]
                   |> :erlang.md5()
                   |> Base.url_encode64(padding: false)

  @signing_salt "ll+Leuc4"

  def start_link(options) do
    options =
      Keyword.validate!(
        options,
        [
          :type,
          :module,
          :port,
          :basename
        ]
      )

    router =
      case options[:type] do
        :controller -> PhoenixPlayground.ControllerRouter
        :live -> PhoenixPlayground.LiveRouter
        :router -> options[:module]
      end

    options = Keyword.put_new(options, :router, router)

    live_reload_options =
      if basename = options[:basename] do
        [
          live_reload: [
            web_console_logger: true,
            debounce: 100,
            patterns: [
              ~r/#{basename}$/
            ],
            notify: [
              {"phoenix_playground", [~r/#{basename}$/]}
            ]
          ]
        ]
      else
        []
      end

    Application.put_env(
      :phoenix_playground,
      __MODULE__,
      [
        adapter: Bandit.PhoenixAdapter,
        http: [ip: {127, 0, 0, 1}, port: options[:port]],
        server: !!options[:port],
        live_view: [signing_salt: @signing_salt],
        secret_key_base: @secret_key_base,
        pubsub_server: PhoenixPlayground.PubSub,
        debug_errors: true,
        phoenix_playground: Map.new(options)
      ] ++ live_reload_options
    )

    super(name: __MODULE__)
  end

  @session_options [
    store: :cookie,
    key: "_phoenix_playground_key",
    signing_salt: @signing_salt,
    same_site: "Lax",
    # 14 days
    max_age: 14 * 24 * 60 * 60
  ]

  socket "/live", Phoenix.LiveView.Socket
  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket

  plug Plug.Static, from: {:phoenix, "priv/static"}, at: "/assets/phoenix"
  plug Plug.Static, from: {:phoenix_live_view, "priv/static"}, at: "/assets/phoenix_live_view"

  plug Phoenix.LiveReloader

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.Session, @session_options

  plug :router

  defp router(conn, []) do
    config = conn.private.phoenix_endpoint.config(:phoenix_playground)
    conn = Plug.Conn.put_private(conn, :phoenix_playground, config)
    config.router.call(conn, [])
  end
end
