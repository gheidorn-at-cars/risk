defmodule Risk.Game do
  require Integer
  require Logger

  alias Risk.{Game, Player}

  @game_settings File.read!("priv/data/game_settings.json") |> Jason.decode!()
  @territories File.read!("priv/data/territories.json")
  # @continents File.read!("priv/data/continents.json") |> Jason.decode!()

  # @derive {Inspect, except: [:territories]}
  defstruct game_settings: @game_settings,
            state: :initialized,
            players: [],
            territories: nil,
            turn: nil,
            turn_order: nil,
            winner: nil

  @type t :: %__MODULE__{
          game_settings: map(),
          state: binary(),
          turn: String.t(),
          turn_order: list(String.t()),
          winner: binary(),
          players: list(Player.t()),
          territories: list(Territory.t())
        }

  defmodule Territory do
    @derive [Poison.Encoder]
    defstruct name: nil,
              continent: nil,
              adjacent: [],
              owner: nil,
              armies: 0

    @type t :: %__MODULE__{
            name: String.t(),
            continent: String.t(),
            adjacent: list(String.t()),
            owner: String.t(),
            armies: integer()
          }
  end

  @doc """
  Creates a game.
  """
  @spec new(list(Player.t())) :: Game.t()
  def new(players \\ [%Player{name: "Player 1"}, %Player{name: "Player 2"}]) do
    # apply game settings
    players = Player.apply_game_settings(players, @game_settings)

    # randomly distribute starting territories
    territories =
      load_territories()
      |> distribute_starting_territories(players)

    # setup the turn order
    turn_order = for p <- Enum.shuffle(players), do: p.name

    %Game{
      players: players,
      territories: territories,
      turn_order: turn_order,
      turn: List.first(turn_order)
    }
  end

  @doc """
  Creates a list of Territories from a JSON file.  You can think of this as initial board state.
  """
  @spec load_territories() :: list(Territory.t())
  def load_territories do
    @territories |> Poison.decode(as: [%Territory{}]) |> elem(1)
  end

  @doc """
  Randomly assign territories to players.
  """
  @spec distribute_starting_territories(list(Territory.t()), list(Player.t())) ::
          list(Territory.t())
  def distribute_starting_territories(territories, players) do
    # get an even number of territories based on the number of players
    num_territories = round(length(territories) / length(players))

    num_territories =
      if Integer.is_odd(num_territories) do
        num_territories - 1
      else
        num_territories
      end

    # select the territories to distribute at random
    territories_to_distribute = Enum.take_random(territories, num_territories)

    {player_one_territories, player_two_territories} =
      Enum.split(territories_to_distribute, Kernel.div(length(territories_to_distribute), 2))

    territories = assign_territories(territories, player_one_territories, List.first(players))
    territories = assign_territories(territories, player_two_territories, List.last(players))

    territories
  end

  @doc """
  Assign a territories to a player.
  """
  @spec assign_territories(list(Territory.t()), list(Territory.t()), Player.t()) ::
          list(Territory.t())
  def assign_territories(territories, [territory_to_assign | remaining_territories], player) do
    {_territory, index} = Game.get_territory(territories, territory_to_assign.name)

    # remove territory from the list
    {_territory_removed, territories_after_pop} = List.pop_at(territories, index)

    # re-add territory with updated owner
    assign_territories(
      [%{territory_to_assign | owner: player.name} | territories_after_pop],
      remaining_territories,
      player
    )
  end

  @spec assign_territories(list(Territory.t()), list(Territory.t()), String.t()) ::
          list(Territory.t())
  def assign_territories(territories, [], _player) do
    territories
  end

  @doc """
  Assign a territory to a player.
  """
  @spec assign_territory(list(Territory.t()), String.t(), Player.t()) :: list(Territory.t())
  def assign_territory(territories, territory_name, player) do
    case Game.get_territory(territories, territory_name) do
      {territory, index} ->
        # remove territory from the list
        {_territory_removed, territories_after_pop} = List.pop_at(territories, index)

        # re-add territory with updated owner
        [%{territory | owner: player.name} | territories_after_pop]

      nil ->
        territories
    end
  end

  @doc """
  Get the territories that are owned by a player.

  ## Examples

  iex> territories = [
  ...>   %Risk.Game.Territory{name: "Brazil", owner: "Player 1"},
  ...>   %Risk.Game.Territory{name: "Venezuela", owner: "Player 1"},
  ...>   %Risk.Game.Territory{name: "Peru", owner: "Player 2"},
  ...>   %Risk.Game.Territory{name: "Argentina", owner: "Player 2"},
  ...>   %Risk.Game.Territory{name: "Ontario", owner: nil}
  ...> ]
  iex> Risk.Game.player_territories(territories, %Risk.Player{armies: 7, name: "Player 1"})
  [
    %Risk.Game.Territory{name: "Brazil", owner: "Player 1"},
    %Risk.Game.Territory{name: "Venezuela", owner: "Player 1"}
  ]

  """
  @spec player_territories(list(Territory.t()), Player.t()) :: list(Territory.t())
  def player_territories(territories, player) do
    territories
    |> Enum.filter(fn territory -> territory.owner == player.name end)
  end

  @doc """
  Get the territories that are not owned by a player.


  ## Examples

  iex> territories = [
  ...>   %Risk.Game.Territory{name: "Brazil", owner: "Player 1"},
  ...>   %Risk.Game.Territory{name: "Venezuela", owner: "Player 1"},
  ...>   %Risk.Game.Territory{name: "Peru", owner: "Player 2"},
  ...>   %Risk.Game.Territory{name: "Argentina", owner: "Player 2"},
  ...>   %Risk.Game.Territory{name: "Ontario", owner: nil}
  ...> ]
  iex> Risk.Game.enemy_territories(territories, %Risk.Player{armies: 7, name: "Player 1"})
  [
    %Risk.Game.Territory{name: "Peru", owner: "Player 2"},
    %Risk.Game.Territory{name: "Argentina", owner: "Player 2"},
    %Risk.Game.Territory{name: "Ontario", owner: nil}
  ]

  """
  @spec enemy_territories(list(Territory.t()), Player.t()) :: list(Territory.t())
  def enemy_territories(territories, player) do
    territories
    |> Enum.filter(fn territory -> territory.owner != player.name end)
  end

  @doc """
  Find a `Territory` by name.  Returns a tuple with the `value` and `index`.
  If the `Territory` doesn't exist, returns `nil`.
  """
  @spec get_territory(list(Territory.t()), String.t()) :: {Territory.t(), integer} | nil
  def get_territory(territories, territory_name) when is_binary(territory_name) do
    territories
    |> Enum.with_index()
    |> Enum.find(fn {territory, _} -> territory.name == territory_name end)
  end

  @spec get_territory(list(Territory.t()), Territory.t()) :: {Territory.t(), integer} | nil
  def get_territory(territories, territory) do
    get_territory(territories, territory.name)
  end

  @doc """
  Find a `Player` by name in a list of `Player`s.  Returns a tuple with the `value` and `index`.
  If the `Player` doesn't exist, returns `nil`.
  """
  @spec get_player(list(Player.t()), String.t()) :: {Player.t(), integer} | nil
  def get_player(players, player_name) when is_binary(player_name) do
    players
    |> Enum.with_index()
    |> Enum.find(fn {player, _} -> player.name == player_name end)
  end

  @spec get_player(list(Player.t()), Player.t()) :: {Player.t(), integer} | nil
  def get_player(players, player) do
    get_player(players, player.name)
  end

  @doc """
  Get the Player's name whose turn it is from the `Game`.
  """
  @spec get_player_by_turn(Game.t()) :: {Player.t(), integer}
  def get_player_by_turn(game) do
    current_turn = Map.get(game, :turn)
    Game.get_player(game.players, current_turn)
  end

  @doc """
  Update the number of armies in a territory that is owned by the player.
  """
  @spec update_territory_armies(list(Territory.t()), String.t(), Player.t(), integer) ::
          {:ok, list(Territory.t())} | {:error, :territory_not_owned}
  def update_territory_armies(territories, territory_name, player, army_size) do
    Logger.debug("update_territory_armies => #{territory_name}, #{player.name}, #{army_size}")

    # check if player owns the tile that they are trying to place an army on
    if player_owns_territory?(territories, territory_name, player) do
      case get_territory(territories, territory_name) do
        {territory, index} ->
          # remove territory from the board
          {_territory_removed, territories_after_pop} = List.pop_at(territories, index)

          # re-add territory with updated armies
          {:ok, [%{territory | armies: territory.armies + army_size} | territories_after_pop]}

        nil ->
          {:error, :territory_not_valid}
      end
    else
      {:error, :territory_not_owned}
    end
  end

  @doc """
  Verify that a player owns a territory.
  """
  @spec player_owns_territory?(list(Territory.t()), String.t(), Player.t()) :: boolean
  def player_owns_territory?(territories, territory_name, player) do
    Logger.debug("player_owns_territory => #{territory_name}, #{player.name}")

    case get_territory(territories, territory_name) do
      {territory, _index} ->
        if territory.owner == player.name do
          true
        else
          false
        end

      nil ->
        false
    end
  end

  @doc """
  Update the number of armies for a Player.
  """
  @spec update_player_armies(Game.t(), Player.t(), integer) :: Game.t()
  def update_player_armies(game, player, num_armies) do
    {player, index} = get_player(game.players, player)

    # remove player from the list of players
    {_player_removed, players_after_pop} = List.pop_at(game.players, index)

    # re-add player with updated armies
    %{game | players: [%{player | armies: num_armies} | players_after_pop]}
  end

  @doc """
  Placing armies increments the armies value for a territory and decrements the armies value for a Player.

  Neither value can be less than 0 (negative).
  """
  @spec place_armies(Game.t(), String.t(), Player.t(), integer) :: {:ok, Game.t()}
  def place_armies(game, territory_name, player, num_armies) do
    Logger.debug(
      "place_armies territory_name: #{territory_name}, player_armies: #{player.armies}, num_armies: #{
        num_armies
      }"
    )

    cond do
      player.armies > 0 && num_armies <= player.armies ->
        case update_territory_armies(game.territories, territory_name, player, num_armies) do
          {:ok, territories} ->
            game =
              %{game | territories: territories}
              |> update_player_armies(player, player.armies - num_armies)

            {:ok, %{game | players: game.players}}

          {:error, message} ->
            Logger.error("place_armies failed: #{message}")
            {:error, message}
        end

      true ->
        message = "place_armies failed: player doesn't have enough remaining armies"
        Logger.error(message)
        {:error, :not_enough_armies}
    end
  end

  @doc """
  Changes the Player whose turn it is in the `Game` based on the `:turn_order`.
  """
  @spec advance_turn(Game.t()) :: {String.t(), Game.t()}
  def advance_turn(game) do
    current_turn_idx = Enum.find_index(game.turn_order, fn x -> x == game.turn end)

    next_turn =
      case Enum.at(game.turn_order, current_turn_idx + 1) do
        nil -> Enum.at(game.turn_order, 0)
        next_turn -> next_turn
      end

    {next_turn, %{game | turn: next_turn}}
  end
end
