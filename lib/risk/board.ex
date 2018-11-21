defmodule Risk.Board do
  alias Risk.Board
  alias Risk.Board.Continent
  alias Risk.Board.Territory

  defstruct territories: [], continents: []

  @type t :: %__MODULE__{
          territories: list(Territory.t()),
          continents: list(Continent.t())
        }

  defmodule Continent do
    defstruct [:name, :reinforcement_value, :territories]

    @type t :: %__MODULE__{
            name: String.t(),
            reinforcement_value: integer(),
            territories: list(String.t())
          }

    # def get_reinforcement_value(continent_name) do
    # end
  end

  defmodule Territory do
    @derive [Poison.Encoder]
    defstruct [:name, :continent, :adjacent, :owner, :armies]

    @type t :: %__MODULE__{
            name: String.t(),
            continent: String.t(),
            adjacent: list(String.t()),
            owner: String.t(),
            armies: integer()
          }
  end

  @territories File.read!("priv/data/territories.json")
  # @continents File.read!("priv/data/continents.json") |> Jason.decode!()

  @spec new() :: Board.t()
  def new do
    %Board{
      territories: load_territories(),
      continents: []
    }

    # build_continents()
  end

  @spec load_territories() :: list(Territory.t())
  def load_territories do
    @territories |> Poison.decode(as: [%Territory{}]) |> elem(1)
  end

  # def build_continents do
  # end

  @spec get_territory(Board.t(), String.t()) :: Territory.t()
  def get_territory(board, name) do
    board.territories
    |> Enum.find(fn territory -> territory.name == name end)
  end

  @doc """
  check if valid attack
  TODO should build a guard and overload to handle either Territory.t or String.t (territory name)
  """
  @spec is_valid_attack?(Territory.t(), Territory.t()) :: boolean()
  def is_valid_attack?(from, to) do
    Enum.any?(from["adjacent"], fn adjacent_tile -> adjacent_tile == to["name"] end)
  end
end
