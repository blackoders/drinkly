defmodule Drinkly.Repo.Migrations.RemoveIdAndAddNewPrimaryKey do
  use Ecto.Migration

  def change do

    alter table(:users) do
      remove :id
      remove :glass_volume
      remove :daily_target
      remove :reminder
      modify(:user_id, :integer, primary_key: true)
    end

  end
end
