
use Mix.Config

config :drinkly, Drinkly.Repo,
  ssl: true,
  queue_target: 10000,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  port: System.get_env("POSTGRESQL_ADDON_PORT"),
  database: System.get_env("POSTGRESQL_ADDON_DB"),
  username: System.get_env("POSTGRESQL_ADDON_USER"),
  password: System.get_env("POSTGRESQL_ADDON_PASSWORD"),
  hostname: System.get_env("POSTGRESQL_ADDON_HOST")

# write production grade code here
