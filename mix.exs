defmodule Drinkly.MixProject do
  use Mix.Project

  def project do
    [
      app: :drinkly,
      version: "0.1.0",
      elixir: "~> 1.9.0",
      build_embedded: Mix.env() == :prod,
      aliases: aliases(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ecto_sql, :postgrex],
      mod: {Drinkly.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_gram, "~> 0.6.0"},
      {:ecto_sql, "~> 3.1.6"},
      {:postgrex, "~> 0.15.0"},
      {:emojix, "~> 0.1.0"},
      {:puppeteer_pdf, "~> 1.0.3"},
      {:quantum, "~> 2.3"},
      {:timex, "~> 3.5"},
      {:jason, "~> 1.0"}
    ]
  end

  defp aliases do
    [
      "drinkly.setup": ["deps.get", "ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp releases() do
    [
      drinkly_linux: [
        include_executables_for: [:unix],
        applicatoins: [runtime_tools: :permanent],
        path: "./drinkly_releases"
      ]
    ]
  end
end
