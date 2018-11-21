defmodule Risk.Game do
  require Integer
  alias Risk.{Game, Board, Player}

  @game_settings File.read!("priv/data/game_settings.json") |> Jason.decode!()

  defstruct phase: "ArmyPlacement", players: [], board: nil, turn: nil, winner: nil

  @type t :: %__MODULE__{
          phase: binary(),
          turn: Player.t(),
          winner: binary(),
          players: list(Player.t()),
          board: Board.t()
        }

  @doc """
  Creates a game with a board.
  """
  @spec new(list(Player.t())) :: Game.t()
  def new(players \\ [%Player{name: "Player 1"}, %Player{name: "Player 2"}]) do
    board = Board.new()

    # apply game settings
    # board = Board.apply_game_setting(board, @game_settings)
    players = Player.apply_game_settings(players, @game_settings)

    # randomly distribute starting territories
    board = distribute_starting_territories(board, players)
    %Game{board: board, players: players, turn: List.first(players)}
  end

  @doc """
  Find a territory by name.  Returns a tuple with the `value` and `index`.
  If the territory doesn't exist, returns `nil`.
  """
  @spec find_territory(Board.t(), String.t()) :: {Territory.t(), integer} | nil
  def find_territory(board, territory_name) do
    board.territories
    |> Enum.with_index()
    |> Enum.find(fn {territory, _} -> territory.name == territory_name end)
  end

  @doc """
  Randomly assign territories to players.
  """
  @spec distribute_starting_territories(Board.t(), list(Player.t())) :: Board.t()
  def distribute_starting_territories(board, players) do
    # get an even number of territories based on the number of players
    num_territories = round(length(board.territories) / length(players))

    num_territories =
      if Integer.is_odd(num_territories) do
        num_territories - 1
      else
        num_territories
      end

    # select the territories to distribute at random
    territories = Enum.take_random(board.territories, num_territories)

    # territories_to_distribute = Enum.take(territories, Kernel.div(num_territories, 2))

    {player_one_territories, player_two_territories} =
      Enum.split(territories, Kernel.div(length(territories), 2))

    board = assign_territories(board, player_one_territories, List.first(players))
    board = assign_territories(board, player_two_territories, List.last(players))

    board
  end

  @doc """
  Assign a territories to a player.
  """
  @spec assign_territories(Board.t(), list(Territory.t()), Player.t()) :: Board.t()
  def assign_territories(board, [territory_to_assign | remaining_territories], player) do
    {_territory, index} = find_territory(board, territory_to_assign.name)

    # remove territory from the board
    {_territory_removed, territories_after_pop} = List.pop_at(board.territories, index)

    # re-add territory with updated owner
    assign_territories(
      %{
        board
        | territories: [%{territory_to_assign | owner: player.name} | territories_after_pop]
      },
      remaining_territories,
      player
    )
  end

  @spec assign_territories(Board.t(), list(Territory.t()), String.t()) :: Board.t()
  def assign_territories(board, [], _player) do
    board
  end

  @doc """
  Assign a territory to a player.
  """
  @spec assign_territory(Board.t(), String.t(), Player.t()) :: Board.t()
  def assign_territory(board, territory_name, player) do
    {territory, index} = find_territory(board, territory_name)

    # remove territory from the board
    {_territory_removed, territories_after_pop} = List.pop_at(board.territories, index)

    # re-add territory with updated owner
    %{board | territories: [%{territory | owner: player.name} | territories_after_pop]}
  end

  @doc """
  Update the number of armies in a territory that is owned by the player.
  """
  @spec update_territory_armies(Board.t(), String.t(), Player.t(), integer) ::
          {:ok, Board.t()} | {:error, :territory_not_owned}
  def update_territory_armies(board, territory_name, player, army_size) do
    # check if player owns the tile that they are trying to place an army on
    if player_owns_territory?(board, territory_name, player) do
      {territory, index} = find_territory(board, territory_name)

      # remove territory from the board
      {_territory_removed, territories_after_pop} = List.pop_at(board.territories, index)

      # re-add territory with updated armies
      {:ok, %{board | territories: [%{territory | armies: army_size} | territories_after_pop]}}
    else
      {:error, :territory_not_owned}
    end
  end

  @doc """
  Verify that a player owns a territory.
  """
  @spec player_owns_territory?(Board.t(), String.t(), Player.t()) :: boolean
  def player_owns_territory?(board, territory_name, player) do
    case find_territory(board, territory_name) do
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
  Get the territories that are owned by a player.
  """
  @spec player_territories(Board.t(), Player.t()) :: list(Territory.t())
  def player_territories(board, player) do
    board.territories
    |> Enum.filter(fn territory -> territory.owner == player.name end)
  end
end
