defmodule Drinkly.Repo do
  use Ecto.Repo,
    otp_app: :drinkly,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
  {:ok, Keyword.put(config, :url, System.get_env("HEROKU_DB_URL"))}
  end
end
