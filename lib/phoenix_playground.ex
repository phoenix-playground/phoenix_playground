defmodule PhoenixPlayground do
  @moduledoc """
  Phoenix Playground makes it easy to create single-file Phoenix applications.
  """

  @doc """
  Starts Phoenix Playground.

  This functions starts Phoenix with a LiveView (`:live`), a controller (`:controller`),
  or a router (`:router`).

  ## Options

    * `:live` - a LiveView module.

    * `:controller` - a controller module.

    * `:router` - a router module.

    * `:port` - port to listen on, defaults to: `4000`.

    * `:open_browser` - whether to open the browser on start, defaults to `true`.
  """
  def start(options) do
    case Supervisor.start_child(PhoenixPlayground.Application, {PhoenixPlayground, options}) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        {:ok, pid}

      other ->
        other
    end
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
        :router,
        port: 4000,
        open_browser: true
      ])

    {type, module} =
      cond do
        live = options[:live] ->
          {:live, live}

        controller = options[:controller] ->
          {:controller, controller}

        router = options[:router] ->
          {:router, router}

        true ->
          raise "missing :live, :controller, or :router"
      end

    if options[:open_browser] do
      Application.put_env(:phoenix, :browser_open, true)
    end

    path = module.__info__(:compile)[:source]
    basename = Path.basename(path)

    # PhoenixLiveReload requires Hex
    Application.ensure_all_started(:hex)
    Application.ensure_all_started(:phoenix_live_reload)

    Application.put_env(:phoenix_live_reload, :dirs, [
      Path.dirname(path)
    ])

    options =
      [
        type: type,
        module: module,
        basename: basename
      ] ++ Keyword.take(options, [:port])

    children = [
      {Phoenix.PubSub, name: PhoenixPlayground.PubSub},
      PhoenixPlayground.Reloader,
      {PhoenixPlayground.Endpoint, options}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
