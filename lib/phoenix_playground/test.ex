defmodule PhoenixPlayground.Test do
  @moduledoc ~S'''
  Conveniences for testing single-file Phoenix apps.

  ## Examples

      Mix.install([
        {:phoenix_playground, "~> 0.1.0"}
      ])

      defmodule DemoLive do
        use Phoenix.LiveView

        def mount(_params, _session, socket) do
          {:ok, assign(socket, count: 0)}
        end

        def render(assigns) do
          ~H"""
          <span>Count: <%= @count %></span> <button phx-click="inc">+</button>
          """
        end

        def handle_event("inc", _params, socket) do
          {:noreply, update(socket, :count, &(&1 + 1))}
        end
      end

      Logger.configure(level: :info)
      ExUnit.start()

      defmodule DemoLiveTest do
        use ExUnit.Case
        use PhoenixPlayground.Test, live: DemoLive

        test "it works" do
          {:ok, view, html} = live(build_conn(), "/")

          assert html =~ "Count: 0"
          assert render_click(view, :inc, %{}) =~ "Count: 1"
          assert render_click(view, :inc, %{}) =~ "Count: 2"
        end
      end
  '''

  defmacro __using__([{type, module}]) do
    module = Macro.expand(module, __ENV__)

    imports =
      if type == :live do
        quote do
          import(Phoenix.LiveViewTest)
        end
      end

    quote do
      import Phoenix.ConnTest
      module = unquote(module)
      type = unquote(type)
      unquote(imports)

      @endpoint PhoenixPlayground.Endpoint
      @options [type: type, module: module]

      setup do
        start_supervised!({@endpoint, @options})
        :ok
      end
    end
  end
end
