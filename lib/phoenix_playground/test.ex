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

  @secret_key_base String.duplicate("a", 32)
  @signing_salt "ll+Leuc4"

  defmacro __using__(options) do
    options =
      Keyword.validate!(options, [
        :live,
        :controller,
        endpoint: PhoenixPlayground.Endpoint
      ])

    imports =
      if options[:live] do
        quote do
          import(Phoenix.LiveViewTest)
        end
      end

    quote do
      import Phoenix.ConnTest
      unquote(imports)

      @endpoint unquote(options[:endpoint])

      setup do
        options = unquote(options)

        if live = options[:live] do
          Application.put_env(:phoenix_playground, :live, live)
        end

        start_supervised!(
          {@endpoint,
           secret_key_base: unquote(@secret_key_base),
           live_view: [signing_salt: unquote(@signing_salt)],
           phoenix_playground: options}
        )

        :ok
      end
    end
  end
end
