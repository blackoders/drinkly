defmodule Drinkly.Drinks do
  alias Drinkly.Users
  alias Drinkly.Repo

  def get_today_drinks(%{user_id: user_id}) do
    _get_today_drinks(user_id)
  end

  def get_today_drinks(user_id) do
    _get_today_drinks(user_id)
  end

  defp _get_today_drinks(user_id) do
    user_id
    |> Users.get_user!()
    |> Repo.preload(:drinks)
    |> Map.get(:drinks)
  end
end
