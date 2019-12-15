use Mix.Config

config :drinkly, Drinkly.Repo,
  database: "drinkly_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :puppeteer_pdf, exec_path: Path.absname("assets/node_modules/.bin/puppeteer-pdf")

config :drinkly,
  report_html_template: Path.join(File.cwd!(), "templates/daily_report.html"),
  report_output_folder: Path.join(File.cwd!(), "pdfs")
