defmodule Drinkly.Metrics.Metric do
  use Ecto.Schema

  import Ecto.Changeset
  alias Drinkly.Users.User

  schema "metrics" do
    field(:glass_size, :string)
    field(:unit, :string)
    field(:daily_target, :string)
    field(:total, :string)
    belongs_to(:user, User, foreign_key: :user_id, references: :user_id)
    timestamps()
  end

  # @required_params ~w(user_name user_id)a
  @cast_params ~w(glass_size unit daily_target total daily_target, user_id)a
  def changeset(metric, params \\ %{}) do
    metric
    |> cast(params, @cast_params)
    |> cast_assoc(:user)
  end
end
