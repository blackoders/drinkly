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

config :puppeteer_pdf, exec_path: Path.absname("assets/node_modules/.bin/puppeteer-pdf")

config :drinkly,
  report_html_template: Path.join(File.cwd!(), "templates/daily_report.html"),
  report_output_folder: Path.join(File.cwd!(), "pdfs")
