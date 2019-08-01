defmodule Drinkly.Repo.Migrations.AlterMetricReferenceColumn do
  use Ecto.Migration

  def change do

    execute "ALTER TABLE metrics DROP CONSTRAINT metrics_user_id_fkey"
    alter table(:metrics) do
      modify :user_id, references(:users, column: :user_id, on_delete: :nothing)
    end
  end
end
