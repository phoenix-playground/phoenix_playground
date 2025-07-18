#!/usr/bin/env elixir
Mix.install([
  {:phoenix_playground, "~> 0.1.7"}
])

defmodule DemoHooks do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <span id="hook" phx-hook="MyHook">LiveView</span>

    <script>
    window.hooks.MyHook = {
      mounted() {
        this.el.innerHTML += " rocks";
        setInterval(() => this.el.innerHTML += "!", 1000);
      }
    }
    </script>

    <style type="text/css">
      body { padding: 1em; }
    </style>
    """
  end
end

PhoenixPlayground.start(live: DemoHooks)
