defmodule Drinkly.Repo.Migrations.ADD_ON_DELETE_OPTION_TO_Drinks_TABLE do
  use Ecto.Migration

  def change do
    alter table(:drinks) do
      modify(:user_id, references(:users, on_delete: :delete_all, column: :user_id))
    end
  end
end
