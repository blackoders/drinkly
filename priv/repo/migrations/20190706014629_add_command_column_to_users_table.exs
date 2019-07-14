defmodule Drinkly.Repo.Migrations.AddCommandColumnToUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:command, :string)
    end
  end
end
