defmodule Risk.GameState do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias Risk.{GameState, Repo}

  @primary_key {:game_id, :binary_id, autogenerate: true}

  schema "games" do
    field :name, :string
    field :state, :string
    field :turn, :string
    field :winner, :string
    field :players, {:array, :map}
    field :turn_order, {:array, :string}
    field :game_settings, :map
    field :territories, {:array, :map}

    timestamps(type: :utc_datetime)
  end

  def changeset(attrs), do: changeset(%__MODULE__{}, attrs)

  def changeset(%__MODULE__{} = game, attrs) do
    game
    |> cast(attrs, [
      :name,
      :state,
      :turn,
      :winner,
      :players,
      :turn_order,
      :game_settings,
      :territories
    ])
    # |> IO.inspect()
    |> validate_required([
      :name,
      :state,
      :turn,
      :players,
      :turn_order,
      :game_settings,
      :territories
    ])
    |> unique_constraint(:name)
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def list_game_states() do
    from(gs in GameState, select: gs)
    |> Repo.all()
  end
end
