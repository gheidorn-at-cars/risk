defmodule Risk.Board do
  alias Risk.Board.Continent
  alias Risk.Board.Tile

  defstruct tiles: [], continents: []

  defmodule Continent do
    defstruct [:name, :reinforcement_value, :tiles]
  end

  defmodule Tile do
    defstruct [:name, :continent, :adjacent_tiles]
  end

  @tiles File.read!("priv/data/map.json") |> Jason.decode!()

  def new do
    load_tiles()
    # build_continents()
  end

  def load_tiles do
    @tiles
  end

  def build_continents do
  end

  def get_tile(map, name) do
    Enum.find(map, fn x -> x["name"] == name end)
  end

  @doc """
  check if valid attack
  """
  def is_valid_attack?(%{} = from_tile, %{} = to_tile) do
    Enum.any?(from_tile["adjacent_tiles"], fn x -> x == to_tile["name"] end)
  end

  def is_valid_attack?(map, from_tile, to_tile) do
    source = get_tile(map, from_tile)
    Enum.any?(source["adjacent_tiles"], fn x -> x == to_tile end)
  end
end
