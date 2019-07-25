defmodule Drinkly.Repo do
  use Ecto.Repo,
    otp_app: :drinkly,
    adapter: Ecto.Adapters.Postgres

end
