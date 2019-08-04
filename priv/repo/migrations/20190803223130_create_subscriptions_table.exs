defmodule Drinkly.Repo.Migrations.CreateSubscriptionsTable do
  use Ecto.Migration

  def change do

    create table(:subscriptions) do
      add :user_id, references(:users, column: :user_id)
      add :status, :boolean, default: true
      add :time, :string, not_null: true

      timestamps()
    end

  end
end
