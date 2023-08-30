defmodule Unsafe.Mixfile do
  use Mix.Project

  @url_docs "http://hexdocs.pm/unsafe"
  @url_github "https://github.com/whitfin/unsafe"

  def project do
    [
      app: :unsafe,
      name: "Unsafe",
      description: "Generate unsafe (!) bindings for Elixir functions",
      package: %{
        files: [
          "lib",
          "mix.exs",
          "LICENSE"
        ],
        licenses: ["MIT"],
        links: %{
          "Docs" => @url_docs,
          "GitHub" => @url_github
        },
        maintainers: ["Isaac Whitfield"]
      },
      version: "1.0.1",
      elixir: "~> 1.2",
      deps: deps(),
      docs: [
        main: "Unsafe",
        source_ref: "master",
        source_url: @url_github
      ],
      test_coverage: [
        tool: ExCoveralls
      ],
      preferred_cli_env: [
        docs: :docs,
        coveralls: :cover,
        "coveralls.html": :cover,
        "coveralls.github": :cover
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.30", optional: true, only: [:docs]},
      {:excoveralls, "~> 0.17", optional: true, only: [:cover]}
    ]
  end
end
