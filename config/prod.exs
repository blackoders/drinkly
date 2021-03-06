use Mix.Config

config :drinkly, Drinkly.Repo,
  ssl: false,
  queue_target: 10000,
  pool_size: 4,
  port: System.get_env("DR_PORT"),
  database: System.get_env("DR_DATABASE"),
  username: System.get_env("DR_USERNAME"),
  password: System.get_env("DR_PASSWORD"),
  hostname: System.get_env("DR_HOSTNAME")

# write production grade code here

config :puppeteer_pdf,
  exec_path: "priv/assets/node_modules/.bin/puppeteer-pdf"

