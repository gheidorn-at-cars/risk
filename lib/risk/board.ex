defmodule Risk.Board do
  alias Risk.Board.Continent
  alias Risk.Board.Territory

  defstruct territories: [], continents: []

  @type t :: %Risk.Board{
          territories: list(Territory.t()),
          continents: list(Continent.t())
        }

  defmodule Continent do
    defstruct [:name, :reinforcement_value, :territories]

    @type t :: %Risk.Board.Continent{
            name: String.t(),
            reinforcement_value: integer(),
            territories: list(String.t())
          }

    def get_reinforcement_value(continent_name) do
    end
  end

  defmodule Territory do
    defstruct [:name, :continent, :adjacent]

    @type t :: %Risk.Board.Territory{
            name: String.t(),
            continent: String.t(),
            adjacent: list(String.t())
          }
  end

  @territories File.read!("priv/data/territories.json") |> Jason.decode!()
  @continents File.read!("priv/data/continents.json") |> Jason.decode!()

  def new do
    load_territories()
    # build_continents()
  end

  def load_territories do
    @territories
  end

  def build_continents do
  end

  def get_territory(board, name) do
    Enum.find(board, fn territory -> territory["name"] == name end)
  end

  @doc """
  check if valid attack
  TODO should build a guard and overload to handle either Territory.t or String.t (territory name)
  """
  @spec is_valid_attack?(Territory.t(), Territory.t()) :: boolean()
  def is_valid_attack?(from, to) do
    Enum.any?(from["adjacent"], fn adjacent_tile -> adjacent_tile == to["name"] end)
  end

  @doc """
  Determine if a player owns continents.
  Returns a tuple with the player and a list of continent names owned.
  """
  def check_continents_owned(board, player) do
  end
end
