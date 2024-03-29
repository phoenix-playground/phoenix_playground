defmodule PhoenixPlayground.ControllerRouter do
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

    get "/", PhoenixPlayground.DelegateController, :index
  end
end

defmodule PhoenixPlayground.LiveRouter do
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
      live "/", PhoenixPlayground.DelegateLive, :index
    end
  end
end

defmodule PhoenixPlayground.DelegateController do
  @moduledoc false

  def init(options) do
    options
  end

  def call(conn, options) do
    %{type: :controller, module: controller} = conn.private.phoenix_playground
    controller.call(conn, controller.init(options))
  end
end

defmodule PhoenixPlayground.DelegateLive do
  @moduledoc false
  use Phoenix.LiveView

  @impl true
  def mount(params, session, socket) do
    live().mount(params, session, socket)
  end

  @impl true
  def render(assigns) do
    live().render(assigns)
  end

  @impl true
  def handle_event(event, params, socket) do
    live().handle_event(event, params, socket)
  end

  @impl true
  def handle_info(message, socket) do
    live().handle_info(message, socket)
  end

  defp live do
    %{type: :live, module: live} = PhoenixPlayground.Endpoint.config(:phoenix_playground)
    live
  end
end
