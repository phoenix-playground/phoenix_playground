defmodule PhoenixPlayground.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_playground,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.0"},
      {:phoenix_live_view, "~> 0.20"},
      {:bandit, "~> 1.0"},
      {:floki, "~> 0.35"},
      # Don't start phoenix_live_reload in case someone just wants PhoenixPlayground.Test.
      # Instead, manually start it in PhoenixPlayground.start_link/1.
      {:phoenix_live_reload, "~> 1.5", runtime: false}
    ]
  end
end
