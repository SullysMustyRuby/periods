defmodule Periods.MixProject do
  use Mix.Project

  @app :periods
  @author "Erin Boeger"
  @github "https://github.com/SullysMustyRuby/periods"
  @license "MIT"
  @name "Periods"
  @version "0.0.2"

  def project do
    [
      app: @app,
      version: @version,
      description: description(),
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # ExDoc
      name: @name,
      source_url: @github,
      homepage_url: @github,
      docs: [
        main: @name,
        canonical: "https://hexdocs.pm/#{@app}",
        extras: ["README.md"]
      ],
      aliases: [
        test: "test --no-start"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Helper for converting and performing math operations on values of time"
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:decimal, "~> 2.1"},
      {:ecto, "~> 1.0 or ~> 2.0 or ~> 2.1 or ~> 3.0", optional: true},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: @app,
      maintainers: [@author],
      licenses: [@license],
      files: ~w(mix.exs lib README.md),
      links: %{"Github" => @github}
    ]
  end
end
