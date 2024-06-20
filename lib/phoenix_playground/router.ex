defmodule PhoenixPlayground.Router do
  @moduledoc false

  @behaviour Plug

  @impl true
  def init([]) do
    []
  end

  @impl true
  def call(conn, []) do
    case PhoenixPlayground.Endpoint.config(:phoenix_playground) do
      [live: _live] ->
        PhoenixPlayground.Router.LiveRouter.call(conn, [])

      [controller: controller] ->
        conn = put_in(conn.private[:phoenix_playground_controller], controller)
        PhoenixPlayground.Router.ControllerRouter.call(conn, [])

      [plug: _] ->
        # always fetch plug from app env to allow code reloading anonymous functions
        plug = Application.fetch_env!(:phoenix_playground, :plug)

        case plug do
          module when is_atom(module) ->
            module.call(conn, module.init([]))

          {module, options} when is_atom(module) ->
            module.call(conn, module.init(options))

          fun when is_function(fun, 1) ->
            fun.(conn)

          fun when is_function(fun, 2) ->
            fun.(conn, [])
        end

      other ->
        raise ArgumentError, "expected :live, :controller, or :plug, got: #{inspect(other)}"
    end
  end

  defmodule ControllerRouter do
    @moduledoc false

    use Phoenix.Router
    import Phoenix.LiveView.Router

    pipeline :browser do
      plug :accepts, ["html", "json"]
      plug :fetch_session
      plug :put_root_layout, html: {PhoenixPlayground.Layouts, :root}
      plug :protect_from_forgery
      plug :put_secure_browser_headers
    end

    scope "/" do
      pipe_through :browser

      get "/", PhoenixPlayground.Router.DelegateController, :index
    end
  end

  defmodule DelegateController do
    @moduledoc false

    def init(options) do
      options
    end

    def call(conn, options) do
      controller = conn.private.phoenix_playground_controller
      controller.call(conn, controller.init(options))
    end
  end

  defmodule LiveRouter do
    @moduledoc false

    use Phoenix.Router
    import Phoenix.LiveView.Router

    pipeline :browser do
      plug :accepts, ["html"]
      plug :fetch_session
      plug :put_root_layout, html: {PhoenixPlayground.Layouts, :root}
      plug :put_secure_browser_headers
    end

    scope "/" do
      pipe_through :browser

      live_session :default, layout: {PhoenixPlayground.Layouts, :live} do
        live "/", PhoenixPlayground.Router.DelegateLive, :index
      end
    end
  end

  defmodule DelegateLive do
    @moduledoc false
    use Phoenix.LiveView

    @impl true
    def mount(params, session, socket) do
      module().mount(params, session, socket)
    end

    @impl true
    def render(assigns) do
      module().render(assigns)
    end

    @impl true
    def handle_params(unsigned_params, uri, socket) do
      if function_exported?(module(), :handle_params, 3),
        do: module().handle_params(unsigned_params, uri, socket),
        else: {:noreply, socket}
    end

    @impl true
    def handle_event(event, params, socket) do
      module().handle_event(event, params, socket)
    end

    @impl true
    def handle_info(message, socket) do
      module().handle_info(message, socket)
    end

    def module do
      Application.fetch_env!(:phoenix_playground, :live)
    end
  end
end
