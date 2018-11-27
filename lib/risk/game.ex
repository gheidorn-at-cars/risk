defmodule Risk.Game do
  require Integer
  require Logger

  alias Risk.{Game, Player}

  @game_settings File.read!("priv/data/game_settings.json") |> Jason.decode!()
  @territories File.read!("priv/data/territories.json")
  # @continents File.read!("priv/data/continents.json") |> Jason.decode!()

  defstruct game_settings: @game_settings,
            state: "Initialized",
            players: [],
            territories: nil,
            turn: nil,
            winner: nil

  @type t :: %__MODULE__{
          game_settings: map(),
          state: binary(),
          turn: Player.t(),
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

    %Game{
      players: players,
      territories: territories,
      turn: List.first(players)
    }
  end

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
  """
  @spec player_territories(list(Territory.t()), Player.t()) :: list(Territory.t())
  def player_territories(territories, player) do
    territories
    |> Enum.filter(fn territory -> territory.owner == player.name end)
  end

  @doc """
  Get the territories that are not owned by a player.
  """
  @spec player_territories(list(Territory.t()), Player.t()) :: list(Territory.t())
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
  Find a `Player` by name.  Returns a tuple with the `value` and `index`.
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
  Update the number of armies in a territory that is owned by the player.
  """
  @spec update_territory_armies(list(Territory.t()), String.t(), Player.t(), integer) ::
          {:ok, list(Territory.t())} | {:error, :territory_not_owned}
  def update_territory_armies(territories, territory_name, player, army_size) do
    # check if player owns the tile that they are trying to place an army on
    if player_owns_territory?(territories, territory_name, player) do
      case get_territory(territories, territory_name) do
        {territory, index} ->
          # remove territory from the board
          {_territory_removed, territories_after_pop} = List.pop_at(territories, index)

          # re-add territory with updated armies
          {:ok, [%{territory | armies: army_size} | territories_after_pop]}

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
  @spec update_player_armies(list(Player.t()), Player.t(), integer) :: list(Player.t())
  def update_player_armies(players, player, num_armies) do
    {player, index} = get_player(players, player)

    # remove player from the list of players
    {_player_removed, players_after_pop} = List.pop_at(players, index)

    # re-add player with updated armies
    [%{player | armies: num_armies} | players_after_pop]
  end

  @doc """
  Placing armies increments the armies value for a territory and decrements the armies value for a Player.

  Neither value can be less than 0 (negative).
  """
  @spec place_armies(Game.t(), Player.t(), String.t(), integer) :: {:ok, Game.t()}
  def place_armies(game, player, territory_name, num_armies) do
    # update the territory's army value
    case update_territory_armies(game.territories, territory_name, player, num_armies) do
      {:ok, territories} ->
        game = %{game | territories: territories}

        # update the player's army value
        new_total = player.armies - num_armies
        players = update_player_armies(game.players, player, new_total)

        game = %{game | players: players}

        {:ok, game}

      {:error, message} ->
        Logger.error("place_armies failed: #{message}")
        {:ok, game}
    end
  end
end
