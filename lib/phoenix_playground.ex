defmodule PhoenixPlayground do
  @moduledoc """
  Phoenix Playground makes it easy to create single-file Phoenix applications.
  """

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

  @doc """
  Starts Phoenix Playground.

  This functions starts Phoenix with a LiveView (`:live`), a controller (`:controller`),
  or a router (`:router`).

  ## Options

    * `:live` - a LiveView module.

      Phoenix Playground adds the following conveniences to the given LiveView:

        * a `:page_title` assign can be used to customise `<head>` `<title>` tag.

        * a `window.hooks` object can be used to register hooks. See `examples/demo_hooks.exs`.

    * `:controller` - a controller module.

    * `:plug` - a plug.

    * `:port` - port to listen on, defaults to: `4000`.

    * `:open_browser` - whether to open the browser on start, defaults to `true`.

    * `:child_specs` - child specs to run in Phoenix Playground supervision tree. The playground
      Phoenix endpoint is automatically added and is always the last child spec. Defaults to `[]`.
  """
  def start(options) do
    options =
      case Application.fetch_env(:phoenix_playground, :file) do
        {:ok, file} ->
          Keyword.put(options, :file, file)

        :error ->
          file = get_file()
          Application.put_env(:phoenix_playground, :file, file)
          Keyword.put(options, :file, file)
      end

    options =
      if router = options[:router] do
        IO.warn("setting :router is deprecated in favour of setting :plug")

        options
        |> Keyword.delete(:router)
        |> Keyword.put(:plug, router)
      else
        options
      end

    if plug = options[:plug] do
      Application.put_env(:phoenix_playground, :plug, plug)
    end

    case Supervisor.start_child(PhoenixPlayground.Application, {PhoenixPlayground, options}) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        # In Livebook, path is nil. Livebook does its own code reloading, this just refreshes LV.
        unless options[:file] do
          Phoenix.PubSub.broadcast(
            PhoenixPlayground.PubSub,
            "live_view",
            {:phoenix_live_reload, :live_view, nil}
          )
        end

        {:ok, pid}

      other ->
        other
    end
  end

  defp get_file do
    {:current_stacktrace, stacktrace} = Process.info(self(), :current_stacktrace)
    get_file(stacktrace)
  end

  defp get_file([
         {PhoenixPlayground, :start, 1, _},
         {_, :__FILE__, 1, meta} | _
       ]) do
    Path.expand(Keyword.fetch!(meta, :file))
  end

  defp get_file([_ | rest]) do
    get_file(rest)
  end

  defp get_file([]) do
    nil
  end

  @doc false
  def child_spec(options) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [options]},
      type: :supervisor
    }
  end

  @doc false
  def start_link(options) do
    options =
      Keyword.validate!(options, [
        :live,
        :controller,
        :plug,
        :file,
        child_specs: [],
        port: 4000,
        open_browser: true
      ])

    child_specs = Keyword.fetch!(options, :child_specs)

    path = options[:file]
    Application.put_env(:phoenix_playground, :file, path)

    if options[:open_browser] do
      Application.put_env(:phoenix, :browser_open, true)
    end

    if live = options[:live] do
      Application.put_env(:phoenix_playground, :live, live)
    end

    # in Livebook, path is nil
    if path do
      Application.put_env(:phoenix_live_reload, :dirs, [
        Path.dirname(path)
      ])
    end

    # PhoenixLiveReload requires Hex
    {:ok, _} = Application.ensure_all_started(:hex)
    {:ok, _} = Application.ensure_all_started(:phoenix_live_reload)

    live_reload_options =
      if options[:live] &&
           unquote(
             # TODO: remove when depending on LV 1.0.
             Version.match?(
               to_string(Application.spec(:phoenix_live_view, :vsn)),
               ">= 1.0.0-rc.1"
             )
           ) do
        [
          # In Livebook, path is nil
          patterns:
            if path do
              # TODO: this should not be needed given we set :phoenix_live_reload :dirs
              [~r/^does_not_matter$/]
            else
              []
            end,
          notify: [
            live_view: [
              ~r/^#{path}$/
            ]
          ]
        ]
      else
        [
          patterns: [
            ~r/^#{path}$/
          ]
        ]
      end

    # Some compile-time options are defined at the top of lib/phoenix_playground/endpoint.ex
    endpoint_options =
      [
        adapter: Bandit.PhoenixAdapter,
        http: [ip: {127, 0, 0, 1}, port: options[:port]],
        server: !!options[:port],
        live_view: [signing_salt: @signing_salt],
        secret_key_base: @secret_key_base,
        pubsub_server: PhoenixPlayground.PubSub,
        live_reload:
          [
            web_console_logger: true,
            debounce: 100,
            reloader: &PhoenixPlayground.CodeReloader.reload/1
          ] ++ live_reload_options,
        phoenix_playground: Keyword.take(options, [:live, :controller, :plug])
      ]

    children =
      child_specs ++
        [
          {Phoenix.PubSub, name: PhoenixPlayground.PubSub},
          {PhoenixPlayground.Endpoint, endpoint_options}
        ]

    System.no_halt(true)
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
