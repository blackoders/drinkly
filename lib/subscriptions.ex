defmodule Drinkly.Subscriptions do
  alias Drinkly.Repo
  alias Drinkly.Users.User

  def list_subscriptions(user_id) do
    Repo.get!(User, user_id)
    |> Repo.preload(:subscriptions)
    |> Map.get(:subscriptions)
  end
end
