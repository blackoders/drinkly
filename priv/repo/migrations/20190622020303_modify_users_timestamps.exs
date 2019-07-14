defmodule Drinkly.Repo.Migrations.ModifyUsersTimestamps do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify(:inserted_at, :timestamp, default: fragment("NOW()"))
      modify(:updated_at, :timestamp, default: fragment("NOW()"))
    end

  end
end
