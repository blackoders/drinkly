defmodule Drinkly.Repo.Migrations.CreateMetricsTable do
  use Ecto.Migration

  def change do
    create table(:metrics) do
      add(:glass_size, :string, default: "250ml")
      add(:unit, :string, default: "ml")
      add(:daily_target, :string, default: "4l")
      add(:total, :string)
      add(:user_id, references(:users))

      timestamps()
    end
  end
end
