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

  def week(user_id) do
    last_n_days(user_id, 7)
  end

  def yesterday(user_id) do
    last_n_days(user_id, 1)
  end

  def last_3_days(user_id) do
    last_n_days(user_id, 3)
  end

  def last_5_days(user_id) do
    last_n_days(user_id, 5)
  end

  def last_n_days(user_id, days) do
    start_date = Timex.today()
    end_date = Timex.shift(start_date, days: -days)
    between(user_id, start_date, end_date)
  end

  def between(user_id, start_date, end_date) do
    drinks_between_query =
      from(d in Drink,
        where:
          fragment("?::date", d.inserted_at) <= ^start_date and
            fragment("?::date", d.inserted_at) >= ^end_date
      )

    user_id
    |> Users.get_user!()
    |> Repo.preload(drinks: drinks_between_query)
    |> Map.get(:drinks)
  end

  def create_drink!(drink) do
    Repo.insert!(drink)
  end

  def create_drink(drink) do
    Repo.insert(drink)
  end

  def create_drink(user_id, text) do
    text = String.trim(text)
    {quantity, unit} = Integer.parse(text)
    unit = String.trim(unit)

    user = Users.get_user!(user_id)

    drink =
      user
      |> Ecto.build_assoc(:drinks)
      |> Drink.changeset(%{quantity: quantity, unit: unit})

    case create_drink(drink) do
      {:ok, _} ->
        " *Drink Added Successfully :)*"

      {:error, changeset} ->
        errors = changeset.errors

        message =
          if errors[:unit] do
            """
            Invalid *unit* specified 
            Supported only *[ml, l, liter, ounce, oz]*
            """
          else
            ""
          end

        if errors[:quantity] do
          message <> "*quantity* should be *>0* "
        else
          message
        end
    end
  end

  def list_drinks(user_id, limit \\ nil) do
    user = Users.get_user!(user_id)

    if limit do
      Repo.preload(user, drinks: limit(Drink, ^limit) |> order_by([d], desc: d.inserted_at))
    else
      Repo.preload(user, drinks: order_by(Drink, [d], desc: d.inserted_at))
    end
  end
end
