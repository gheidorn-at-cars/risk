defmodule Risk.Game do
  defstruct players: [], board: nil, turn: nil, winner: nil
  require Integer
  alias Risk.{Game, Board}

  @doc """
  Creates a game with a board.
  """
  def new() do
    board = Board.new()
    players = ["player1", "player2"]
    # add starting armies to each players warchest
    # randomly distribute starting territories
    board = distribute_starting_territories(board, players)
    %Game{board: board, players: players, turn: List.first(players)}
  end

  @doc """
  Find a territory by name.  Returns a tuple with the `value` and `index`.
  If the territory doesn't exist, returns `nil`.
  """
  def find_territory(board, territory_name) do
    board
    |> Enum.with_index()
    |> Enum.find(fn {territory, _} -> territory["name"] == territory_name end)
  end

  @doc """
  Randomly assign territories to players.
  """
  def distribute_starting_territories(board, players) do
    # get an even number of territories based on the number of players
    num_territories = round(length(board) / length(players))

    num_territories =
      if Integer.is_odd(num_territories) do
        num_territories - 1
      else
        num_territories
      end

    # select the territories to distribute at random
    territories = Enum.take_random(board, num_territories)

    territories_to_distribute = Enum.take(territories, Kernel.div(num_territories, 2))

    board = assign_territories(board, territories_to_distribute, "player1")

    # board = update_board(board, group1)

    board
  end

  @doc """
  Updating the board involves removing the territories with old state and re-adding the territories with new state.
  """
  def update_board(board, [first_territory | remaining_territories]) do
    {_territory, index} = find_territory(board, first_territory.name)

    # remove territory from the board
    {_territory_removed, board} = List.pop_at(board, index)

    # re-add territory with updated owner
    update_board([first_territory | board], remaining_territories)
  end

  def update_board(board, []) do
    board
  end

  @doc """
  Assign a territories to a player.
  """
  def assign_territories(board, [first_territory | remaining_territories], player) do
    {_territory, index} = find_territory(board, first_territory["name"])

    # remove territory from the board
    {_territory_removed, board} = List.pop_at(board, index)

    # update territory with new owner
    first_territory = Map.put(first_territory, "owner", player)

    # re-add territory with updated owner
    assign_territories([first_territory | board], remaining_territories, player)
  end

  def assign_territories(board, [], _player) do
    board
  end

  @doc """
  Assign a territory to a player.
  """
  def assign_territory(board, territory_name, player) do
    {territory, index} = find_territory(board, territory_name)

    # remove territory from the board
    {_territory_removed, updated_board} = List.pop_at(board, index)

    # update territory with new owner
    updated_territory = Map.put(territory, "owner", player)

    # re-add territory with updated owner
    [updated_territory | updated_board]
  end

  @doc """
  Update the number of armies in a territory that is owned by the player.
  """
  def update_territory_armies(board, territory_name, player, army_size) do
    # check if player owns the tile that they are trying to place an army on
    if player_owns_territory?(board, territory_name, player) do
      {territory, index} = find_territory(board, territory_name)

      # remove territory from the board
      {_territory_removed, updated_board} = List.pop_at(board, index)

      # update territory with new amount of armies
      updated_territory = Map.put(territory, "armies", army_size)

      # re-add territory with updated armies
      {:ok, [updated_territory | updated_board]}
    else
      {:error, :territory_not_owned}
    end
  end

  @doc """
  Verify that a player owns a territory.
  """
  def player_owns_territory?(board, territory_name, player) do
    case find_territory(board, territory_name) do
      {territory, _index} ->
        if territory["owner"] == player do
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
  def player_territories(board, player) do
    board
    |> Enum.filter(fn territory -> territory["owner"] == player end)
  end
end
