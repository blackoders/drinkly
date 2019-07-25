defmodule Drinkly.MixProject do
  use Mix.Project

  def project do
    [
      app: :drinkly,
      version: "0.1.0",
      elixir: "~> 1.8",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:emojix, "~> 0.1.0"},
      # Only one of this
      {:jason, ">= 1.0.0"}
    ]
  end
end
