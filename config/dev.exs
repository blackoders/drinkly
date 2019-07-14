use Mix.Config

config :drinkly, Drinkly.Repo,
  database: "drinkly_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :drinkly, ecto_repos: [Drinkly.Repo]
