defmodule Drinkly.Subscriptions.Subscription do
  use Ecto.Schema

  import Ecto.Changeset
  alias __MODULE__

  @primary_key {:subscription_id, :integer, [auto_generate: false]}
  schema "subscriptions" do
    field(:time, :string)
    field(:status, :boolean)
    belongs_to(:user, User, foreign_key: :user_id, references: :user_id)

    timestamps()
  end

  # @required_params ~w(user_name user_id)a
  @cast_params ~w(time status user_id)a
  @required_params ~w(time status)a
  def changeset(subscription, params \\ %{}) do
    subscription
    |> cast(params, @cast_params)
    |> validate_required(@required_params)
    |> cast_assoc(:user)
    |> assoc_constraint(:user)
    |> validate_subscription_time(params)
  end

  defp validate_subscription_time(changeset, :time, options \\ []) do
    validate_change(changeset, :time, fn _, time ->
      timings = for x <- 1..23, do: "#{x}h"

      if time in [timings] do
        []
      else
        [{:time, options[:message] || "Invalid Time Representation"}]
      end
    end)
  end
end
