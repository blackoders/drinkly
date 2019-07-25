use Mix.Config

config :drinkly, Drinkly.Repo,
  ssl: true,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  url: System.get_env("HEROKU_POSTGRESQL_ROSE_URL")
  # port: 5432,
  # database: "d4mncl7664siva",
  # username: "pedfekzzlqxabq",
  # password: "ed2aaae757306430b21ece62aa5f58222c79442f835b29b1a381188aef4f0f55",
  # hostname: "ec2-174-129-227-205.compute-1.amazonaws.com"

# write production grade code here
