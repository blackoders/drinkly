defmodule Drinkly.Repo.Migrations.UsersTableCreate do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :daily_target, :string
      add :email, :string
      add :first_name, :string
      add :glass_volume, :string
      add :reminder, :string
      add :user_id, :integer
      add :user_name, :string

      timestamps()
    end
  end
end
