defmodule Risk.Game do
  require Integer
  require Logger

  alias Risk.{Game, Player}

  @game_settings File.read!("priv/data/game_settings.json") |> Jason.decode!()
  @territories File.read!("priv/data/territories.json")
  # @continents File.read!("priv/data/continents.json") |> Jason.decode!()

  # @derive {Inspect, except: [:territories]}
  defstruct name: nil,
            state: "Initialized",
            turn: nil,
            winner: nil,
            players: [],
            turn_order: nil,
            game_settings: @game_settings,
            territories: nil

  @type t :: %Game{
          name: String.t(),
          state: String.t(),
          turn: String.t(),
          winner: String.t(),
          players: list(Player.t()),
          turn_order: list(String.t()),
          game_settings: map(),
          territories: list(Territory.t())
        }

  defmodule Territory do
    @derive [Jason.Encoder]
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
  @spec new(String.t(), list(map())) :: map()
  def new(name, players)
      when is_binary(name)
      when is_list(players) do
    # apply game settings
    players = Player.apply_game_settings(players, @game_settings)

    # randomly distribute starting territories
    territories =
      load_territories()
      |> distribute_starting_territories(players)

    # setup the turn order
    turn_order = for p <- Enum.shuffle(players), do: p["name"]

    %{
      "name" => name,
      "state" => "Initialized",
      "players" => players,
      "game_settings" => @game_settings,
      "territories" => territories,
      "turn_order" => turn_order,
      "turn" => List.first(turn_order)
    }
  end

  @doc """
  Creates a list of Territories from a JSON file.  You can think of this as initial board state.
  """
  @spec load_territories() :: list(Territory.t())
  def load_territories do
    # @territories |> Poison.decode(as: [%Territory{}]) |> elem(1)
    @territories |> Jason.decode() |> elem(1)
  end

  @doc """
  Randomly assign territories to players.
  """
  @spec distribute_starting_territories(list(map()), list(map())) ::
          list(map())
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
  @spec assign_territories(list(map()), list(map()), map()) ::
          list(map())
  def assign_territories(territories, [territory_to_assign | remaining_territories], player) do
    # Logger.debug("inside assign_territories")
    # Logger.debug("#{inspect(territory_to_assign)}")
    # Logger.debug("#{inspect(remaining_territories)}")

    {_territory, index} = Game.get_territory(territories, territory_to_assign["name"])

    # remove territory from the list
    {_territory_removed, territories_after_pop} = List.pop_at(territories, index)

    # re-add territory with updated owner

    assign_territories(
      # [%{territory_to_assign | "owner" => player["name"]} | territories_after_pop],
      [Map.put(territory_to_assign, "owner", player["name"]) | territories_after_pop],
      remaining_territories,
      player
    )
  end

  @spec assign_territories(list(map()), list(map()), String.t()) ::
          list(map())
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
        [Map.put(territory, "owner", player["name"]) | territories_after_pop]

      nil ->
        territories
    end
  end

  @doc """
  Get the territories that are owned by a player.

  ## Examples

  iex> territories = [
  ...>   %{"name" => "Brazil", "owner" => "Player 1"},
  ...>   %{"name" => "Venezuela", "owner" => "Player 1"},
  ...>   %{"name" => "Peru", "owner" => "Player 2"},
  ...>   %{"name" => "Argentina", "owner" => "Player 2"},
  ...>   %{"name" => "Ontario", "owner" => nil}
  ...> ]
  iex> Risk.Game.player_territories(territories, %{"armies" => 7, "name" => "Player 1"})
  [
    %{"name" => "Brazil", "owner" => "Player 1"},
    %{"name" => "Venezuela", "owner" => "Player 1"}
  ]

  """
  @spec player_territories(list(Territory.t()), Player.t()) :: list(Territory.t())
  def player_territories(territories, player) do
    territories
    |> Enum.filter(fn territory -> territory["owner"] == player["name"] end)
  end

  @doc """
  Get the territories that are not owned by a player.


  ## Examples

  iex> territories = [
  ...>   %{"name" => "Brazil", "owner" => "Player 1"},
  ...>   %{"name" => "Venezuela", "owner" => "Player 1"},
  ...>   %{"name" => "Peru", "owner" => "Player 2"},
  ...>   %{"name" => "Argentina", "owner" => "Player 2"},
  ...>   %{"name" => "Ontario", "owner" => nil}
  ...> ]
  iex> Risk.Game.enemy_territories(territories, %{"armies" => 7, "name" => "Player 1"})
  [
    %{"name" => "Peru", "owner" => "Player 2"},
    %{"name" => "Argentina", "owner" => "Player 2"},
    %{"name" => "Ontario", "owner" => nil}
  ]

  """
  @spec enemy_territories(list(Territory.t()), Player.t()) :: list(Territory.t())
  def enemy_territories(territories, player) do
    territories
    # |> Enum.filter(fn territory ->
    #   territory["owner"] == nil
    # end)
    |> Enum.filter(fn territory ->
      territory["owner"] != player["name"]
    end)
  end

  @doc """
  Find a `Territory` by name.  Returns a tuple with the `value` and `index`.
  If the `Territory` doesn't exist, returns `nil`.
  """
  @spec get_territory(list(map()), String.t()) :: {map(), integer} | nil
  def get_territory(territories, territory_name) when is_binary(territory_name) do
    territories
    |> Enum.with_index()
    |> Enum.find(fn {territory, _} -> territory["name"] == territory_name end)
  end

  @spec get_territory(list(map()), map()) :: {map(), integer} | nil
  def get_territory(territories, territory) when is_map(territory) do
    get_territory(territories, territory["name"])
  end

  def get_territory(_territories, territory) when is_nil(territory) do
    nil
  end

  @doc """
  Find a `Player` by name in a list of `Player`s.  Returns a tuple with the `value` and `index`.
  If the `Player` doesn't exist, returns `nil`.
  """
  @spec get_player(list(map()), String.t()) :: {map(), integer} | nil
  def get_player(players, player_name) when is_binary(player_name) do
    players
    |> Enum.with_index()
    |> Enum.find(fn {player, _} -> player["name"] == player_name end)
  end

  @spec get_player(list(map()), map()) :: {map(), integer} | nil
  def get_player(players, player) when is_map(player) do
    get_player(players, player["name"])
  end

  def get_player(_players, player) when is_nil(player) do
    nil
  end

  @doc """
  Get the Player's name whose turn it is from the `Game`.
  """
  @spec get_player_by_turn(map()) :: {map(), integer}
  def get_player_by_turn(game) do
    get_player(game["players"], game["turn"])
  end

  @doc """
  Update the number of armies in a territory that is owned by the player.
  """
  @spec update_territory_armies(list(Territory.t()), String.t(), Player.t(), integer) ::
          {:ok, list(Territory.t())} | {:error, :territory_not_owned}
  def update_territory_armies(territories, territory_name, player, army_size) do
    Logger.debug("update_territory_armies => #{territory_name}, #{player["name"]}, #{army_size}")

    # check if player owns the tile that they are trying to place an army on
    if player_owns_territory?(territories, territory_name, player) do
      case get_territory(territories, territory_name) do
        {territory, index} ->
          # remove territory from the board
          {_territory_removed, territories_after_pop} = List.pop_at(territories, index)

          # re-add territory with updated armies
          # {:ok, [%{territory | armies: territory["armies"] + army_size} | territories_after_pop]}

          updated_territory =
            Map.get(territory, "armies", 0)
            |> Kernel.+(army_size)
            |> (&Map.put(territory, "armies", &1)).()

          {:ok, [updated_territory | territories_after_pop]}

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
    Logger.debug("player_owns_territory => #{territory_name}, #{player["name"]}")

    case get_territory(territories, territory_name) do
      {territory, _index} ->
        if territory["owner"] == player["name"] do
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
    {player, index} = get_player(game["players"], player)

    # remove player from the list of players
    {_player_removed, players_after_pop} = List.pop_at(game["players"], index)

    # re-add player with updated armies
    [Map.put(player, "armies", num_armies) | players_after_pop]
    |> (&Map.put(game, "players", &1)).()
  end

  @doc """
  Placing armies increments the armies value for a territory and decrements the armies value for a Player.

  Neither value can be less than 0 (negative).
  """
  @spec place_armies(Game.t(), String.t(), Player.t(), integer) :: {:ok, Game.t()}
  def place_armies(game, territory_name, player, num_armies) do
    Logger.debug(
      "place_armies territory_name: #{territory_name}, player_armies: #{player["armies"]}, num_armies: #{
        num_armies
      }"
    )

    cond do
      player["armies"] > 0 && num_armies <= player["armies"] ->
        case update_territory_armies(game["territories"], territory_name, player, num_armies) do
          {:ok, territories} ->
            game =
              Map.put(game, "territories", territories)
              |> update_player_armies(player, player["armies"] - num_armies)

            {:ok, %{game | "players" => game["players"]}}

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
    current_turn_idx = Enum.find_index(game["turn_order"], fn x -> x == game["turn"] end)

    next_turn =
      case Enum.at(game["turn_order"], current_turn_idx + 1) do
        nil -> Enum.at(game["turn_order"], 0)
        next_turn -> next_turn
      end

    {next_turn, Map.put(game, "turn", next_turn)}
  end
end
