defmodule Drinkly.Users.User do
  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field(:first_name, :string)
    field(:user_name, :string)
    field(:user_id, :integer)
    field(:glass_volume, :string)
    field(:daily_target, :string)
    field(:reminder, :string)
    field(:email, :string)
    field(:command, :string)
  end

  @required_params ~w(user_name user_id)a
  @cast_params ~w(first_name user_name user_id glass_volume daily_target reminder email command)a
  def changeset(user, params \\ %{}) do
    user
    |> cast(params, @cast_params)
    |> unique_constraint(:user_name)
    |> unique_constraint(:user_id)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> validate_required(@required_params)
  end
end
