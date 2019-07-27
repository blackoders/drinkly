defmodule Drinkly.Drinks.Drink do
  use Ecto.Schema

  import Ecto.Changeset

  schema "drinks" do
    field(:quantity, :integer)
    field(:unit, :string)
    belongs_to(:user, User)

    timestamps()
  end

  # @required_params ~w(user_name user_id)a
  @cast_params ~w(unit quantity, user_id)a
  def changeset(metric, params \\ %{}) do
    metric
    |> cast(params, @cast_params)
    |> cast_assoc(:user)
  end
end
