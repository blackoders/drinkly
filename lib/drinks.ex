defmodule Drinkly.Drinks do
  import Ecto.Query, warn: false
  require Logger

  alias Drinkly.Repo
  alias Drinkly.Helper
  alias Drinkly.Users
  alias Drinkly.Drinks.Drink

  @doc """
  It gives list of drinks in a day
  """
  def today(user_id) do
    date = Helper.today_date()
    today_drinks_query = from(d in Drink, where: fragment("?::date", d.inserted_at) == ^date)

    user_id
    |> Users.get_user!()
    |> Repo.preload(drinks: today_drinks_query)
    |> Map.get(:drinks)
  end

  def between(user_id, start_date, end_date) do
    drinks_between_query =
      from(d in Drink,
        where:
          fragment("?::date", d.inserted_at) >= ^start_date and
            fragment("?::date", d.inserted_at) <= ^end_date
      )

    user_id
    |> Users.get_user!()
    |> Repo.preload(drinks: drinks_between_query)
    |> Map.get(:drinks)
  end

  def create_drink(%Drink{} = drink) do
    Repo.insert!(drink)
  end
end
