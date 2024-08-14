defmodule PhoenixPlayground.MixProject do
  use Mix.Project

  @source_url "https://github.com/phoenix-playground/phoenix_playground"
  @version "0.1.5"

  def project do
    [
      app: :phoenix_playground,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      package: package(),
      aliases: aliases(),
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {PhoenixPlayground.Application, []}
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

  defp aliases do
    [
      docs: ["docs.setup", "docs", "docs.teardown"],
      "docs.setup": &docs_setup/1,
      "docs.teardown": &docs_teardown/1
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
      ],
      assets: %{"assets" => "assets"},
      skip_code_autolink_to: [
        "PhoenixPlayground.start_link/1"
      ]
    ]
  end

  defp docs_setup(_) do
    tmp = "#{__DIR__}/tmp"
    File.mkdir_p!(tmp)
    File.cp!("#{__DIR__}/README.md", "#{tmp}/README.md")

    File.write!("#{__DIR__}/README.md", [
      File.read!("#{__DIR__}/README.md"),
      "\n\n",
      for path <- Path.wildcard("examples/*.exs") do
        "[`#{path}`]: https://github.com/phoenix-playground/phoenix_playground/blob/v#{@version}/#{path}\n"
      end
    ])
  end

  defp docs_teardown(_) do
    tmp = "#{__DIR__}/tmp"
    File.rename!("#{tmp}/README.md", "#{__DIR__}/README.md")
  end

  defp deps do
    [
      {:phoenix, "~> 1.0"},
      {:phoenix_live_view, "~> 0.20.0 or ~> 1.0-rc"},
      {:bandit, "~> 1.0"},
      {:jason, "~> 1.0"},
      {:floki, "~> 0.35"},

      # Don't start phoenix_live_reload in case someone just wants PhoenixPlayground.Test.
      # Instead, manually start it in PhoenixPlayground.start_link/1.
      {:phoenix_live_reload, "~> 1.5", runtime: false},

      # dev-only
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
