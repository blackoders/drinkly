defmodule Drinkly.Repo.Migrations.UniqueIndexesUsers do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:user_id])
    create unique_index(:users, [:email])
    create unique_index(:users, [:user_name])
  end
end
