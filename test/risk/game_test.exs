defmodule Risk.GameTest do
  use ExUnit.Case
  alias Risk.{Board, Game, Player}
  alias Risk.Board.Territory

  @territory_name "Ontario"
  @territory_continent "North America"
  @territory_adjacent [
    "Alberta",
    "Northwest Territory",
    "Western United States",
    "Eastern Canada",
    "Eastern United States",
    "Ontario",
    "Greenland"
  ]

  @territory_name_two "Alberta"
  @player_one %Player{
    name: "Abe Lincoln",
    armies_to_place: 5
  }
  @player_two %Player{
    name: "Winston Churchill",
    armies_to_place: 5
  }

  setup do
    %{board: Board.new(), players: [@player_one, @player_two]}
  end

  test "find_territory", %{board: board} do
    {territory, _index} = Game.find_territory(board, @territory_name)

    assert territory.name == @territory_name
    assert territory.continent == @territory_continent
    assert territory.adjacent == @territory_adjacent
    assert is_nil(territory.owner)

    assert is_nil(Game.find_territory(board, "Ontario123"))
  end

  test "assign_territory", %{board: board} do
    # confirm there is no owner prior to assign_territory
    {territory, _index} = Game.find_territory(board, @territory_name)
    assert is_nil(territory.owner)

    # assign_territory
    board = Game.assign_territory(board, @territory_name, @player_one)
    assert length(board.territories) == length(board.territories)

    # confirm the territory was updated on the board
    {territory, _index} = Game.find_territory(board, @territory_name)
    assert territory.owner == @player_one.name
  end

  test "assign_territories", %{board: board, players: players} do
    territory_group_one = [
      %Territory{
        name: "Alaska",
        continent: "North America",
        adjacent: ["Northwest Territory", "Alberta", "Kamchatka"]
      },
      %Territory{
        name: "Alberta",
        continent: "North America",
        adjacent: [
          "Alaska",
          "Northwest Territory",
          "Western United States",
          "Ontario",
          "Greenland"
        ]
      }
    ]

    territory_group_two = [
      %Territory{
        name: "Venezuela",
        continent: "South America",
        adjacent: ["Central America", "Peru", "Brazil"]
      },
      %Territory{
        name: "Brazil",
        continent: "South America",
        adjacent: ["Venezuela", "Peru", "Argentina", "North Africa"]
      }
    ]

    player1 = List.first(players)
    board = Game.assign_territories(board, territory_group_one, player1)
    {alaska, _index} = Game.find_territory(board, "Alaska")
    {alberta, _index} = Game.find_territory(board, "Alberta")

    assert alaska.owner == player1.name
    assert alberta.owner == player1.name

    player2 = List.last(players)
    board = Game.assign_territories(board, territory_group_two, player2)
    {venezuela, _index} = Game.find_territory(board, "Venezuela")
    {brazil, _index} = Game.find_territory(board, "Brazil")

    assert venezuela.owner == player2.name
    assert brazil.owner == player2.name
  end

  test "update_territory_armies", %{board: board} do
    # confirm that no armies exist on a new board
    {territory, _index} = Game.find_territory(board, @territory_name)
    assert is_nil(territory.armies)

    # try to update territories when territory is not owned
    case Game.update_territory_armies(board, @territory_name, @player_one, 5) do
      {:ok, _board} -> flunk("can't update armies if territory is not owned")
      {:error, message} -> assert message == :territory_not_owned
    end

    board = Game.assign_territory(board, @territory_name, @player_one)

    # try to update territories when territory is owned
    case Game.update_territory_armies(board, @territory_name, @player_one, 5) do
      {:ok, board} ->
        {updated_territory, _index} = Game.find_territory(board, @territory_name)
        assert updated_territory.armies == 5

      {:error, _message} ->
        flunk("should be able to update armies")
    end
  end

  test "player_owns_territory?", %{board: board} do
    # confirm no one owns territory
    {territory, _index} = Game.find_territory(board, @territory_name)
    assert is_nil(territory.owner)

    # assign_territory
    updated_board = Game.assign_territory(board, @territory_name, @player_one)

    # confirm that field is no longer nil
    {updated_territory, _index} = Game.find_territory(updated_board, @territory_name)
    refute is_nil(updated_territory.owner)

    # confirm API is working
    assert Game.player_owns_territory?(updated_board, @territory_name, @player_one) == true
    assert Game.player_owns_territory?(updated_board, @territory_name, @player_two) == false
  end

  test "player_territories", %{board: board} do
    board = Game.assign_territory(board, @territory_name, @player_one)
    board = Game.assign_territory(board, @territory_name_two, @player_one)

    territories = Game.player_territories(board, @player_one)

    assert length(territories) == 2
    for t <- territories, do: assert(t.owner == @player_one.name)
    for t <- territories, do: assert(t.name == @territory_name || t.name == @territory_name_two)
  end

  test "distribute_starting_territories", %{board: board, players: players} do
    board = Game.distribute_starting_territories(board, players)
    assert length(Game.player_territories(board, List.first(players))) > 0
    assert length(Game.player_territories(board, List.last(players))) > 0
  end
end
