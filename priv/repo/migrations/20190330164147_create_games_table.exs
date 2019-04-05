defmodule Risk.Repo.Migrations.CreateGamesTable do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :game_id, :uuid, primary_key: true
      add :state, :string, null: false
      add :name, :string, null: false
      add :turn, :string, null: false
      add :winner, :string
      add :players, {:array, :map}
      add :turn_order, {:array, :string}
      add :game_settings, :map
      add :territories, {:array, :map}

      timestamps()
    end

    create index(:games, [:game_id])
    create unique_index(:games, [:name])
  end
end
