defmodule Drinkly.Drinks.Drink do
  use Ecto.Schema

  import Ecto.Changeset
  alias Drinkly.Users.User

  @units ~w(ml l oz liter ounce)

  schema "drinks" do
    field(:quantity, :integer)
    field(:unit, :string)
    belongs_to(:user, User, foreign_key: :user_id, references: :user_id)

    timestamps()
  end

  # @required_params ~w(user_name user_id)a
  @cast_params ~w(unit quantity user_id)a
  def changeset(drink, params \\ %{}) do
    drink
    |> cast(params, @cast_params)
    |> cast_assoc(:user)
    |> assoc_constraint(:user)
    |> validate_inclusion(:unit, @units)
    |> validate_number(:quantity, greater_than: 0.0)
  end
end
