defmodule Drinkly.Users.User do
  use Ecto.Schema

  alias Drinkly.Metrics.Metric
  alias Drinkly.Drinks.Drink
  alias Drinkly.Subscriptions.Subscription

  import Ecto.Changeset

  @primary_key {:user_id, :integer, [auto_generate: false]}
  schema "users" do
    field(:first_name, :string)
    field(:user_name, :string)
    field(:email, :string)
    field(:command, :string)
    has_one(:metric, Metric, foreign_key: :user_id)
    has_many(:drinks, Drink, foreign_key: :user_id)
    has_many(:subscriptions, Subscription, foreign_key: :user_id)
  end

  @required_params ~w(user_name)a
  @cast_params ~w(first_name user_name email command user_id)a
  def changeset(user, params \\ %{}) do
    user
    |> cast(params, @cast_params)
    |> cast_assoc(:metric)
    |> unique_constraint(:user_name)
    |> update_change(:email, &change_email/1)
    |> unique_constraint(:email)
    |> validate_required(@required_params)
  end

  defp change_email(nil) do
    nil
  end

  defp change_email(email) do
    email = String.trim(email)

    case email do
      "" -> nil
      email -> String.downcase(email)
    end
  end
end
