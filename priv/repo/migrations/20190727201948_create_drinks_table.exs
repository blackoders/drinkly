defmodule Drinkly.Repo.Migrations.CreateDrinksTable do
  use Ecto.Migration

  def change do

    create table(:drinks) do
      add :quantity, :integer
      add :unit, :string
      add :user_id, references(:users, column: :user_id)

      timestamps()
    end

    create index(:drinks, [:quantity, :unit])
  end
end
