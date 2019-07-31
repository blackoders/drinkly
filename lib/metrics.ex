defmodule Drinkly.Metrics do
  import Ecto.Query, warn: false

  require Logger
  alias Drinkly.Repo
  # alias Drinkly.Helper
  alias Drinkly.Metrics.Metric
  alias Drinkly.Users

  def update!(user_id, changes) do
    user =
      user_id
      |> Users.get_user!()
      |> Repo.preload(:metric)

    if user.metric do
      metric = Ecto.Changeset.change(user.metric, changes)
      Repo.update(metric)
    else
      create_metric(user_id, changes)
    end
  end

  def get_metric_by!(user_id: user_id) do
    Repo.get_by!(Metric, user_id: user_id)
  end

  def create_metric(user, metrics) when is_map(user) do
    metric = Ecto.build_assoc(user, :metric, metrics)
    Repo.insert(metric)
  end

  def create_metric(user_id, metrics) do
    user = Users.get_user!(user_id)

    create_metric(user, metrics)
  end
end
