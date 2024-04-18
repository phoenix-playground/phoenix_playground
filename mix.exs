defmodule PhoenixPlayground.MixProject do
  use Mix.Project

  @source_url "https://github.com/phoenix-playground/phoenix_playground"
  @version "0.1.0"

  def project do
    [
      app: :phoenix_playground,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      description: "Phoenix Playground makes it easy to create single-file Phoenix applications",
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "https://hexdocs.pm/phoenix_playground/changelog.html"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: [
        "README.md",
        "CHANGELOG.md"
      ]
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
      {:phoenix_live_reload, "~> 1.5", runtime: false},

      # dev-only
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
