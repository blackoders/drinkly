use Mix.Config

config :drinkly, Drinkly.Repo,
  ssl: false,
  pool_size: 15
  # url: {:system, "HEROKU_DB_URL"},

  # database: "drinkly_dev",
  # username: "postgres",
  # password: "postgres",
  # hostname: "localhost"

# write production grade code here
