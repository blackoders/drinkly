defmodule Drinkly.Drinks.Drink do
  use Ecto.Schema

  import Ecto.Changeset
  alias Drinkly.Users.User

  schema "drinks" do
    field(:quantity, :integer)
    field(:unit, :string)
    belongs_to(:user, User, foreign_key: :user_id, references: :user_id)

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
