defmodule Risk.GameTest do
  use ExUnit.Case
  alias Risk.{Board, Game}

  @territory_name "Ontario"
  @territory_name_two "Alberta"
  @player_one "Abe Lincoln"
  @player_two "Winston Churchill"

  setup do
    %{board: Board.new(), players: [@player_one, @player_two]}
  end

  test "find_territory", %{board: board} do
    {territory, _index} = Game.find_territory(board, @territory_name)

    assert territory == %{
             "adjacent_tiles" => [
               "Alberta",
               "Northwest Territory",
               "Western United States",
               "Eastern Canada",
               "Eastern United States",
               "Ontario",
               "Greenland"
             ],
             "continent" => "North America",
             "name" => "Ontario"
           }

    assert territory["name"] == @territory_name

    assert is_nil(Game.find_territory(board, "Ontario123"))
  end

  test "assign_territory", %{board: board} do
    # confirm there is no owner prior to assign_territory
    {territory, _index} = Game.find_territory(board, @territory_name)
    assert is_nil(territory["owner"])

    # assign_territory
    updated_board = Game.assign_territory(board, @territory_name, @player_one)
    assert length(board) == length(updated_board)

    # confirm the territory was updated on the board
    {updated_territory, _index} = Game.find_territory(updated_board, @territory_name)
    assert updated_territory["owner"] == @player_one
  end

  test "update_territory_armies", %{board: board} do
    # confirm that no armies exist on a new board
    {territory, _index} = Game.find_territory(board, @territory_name)
    assert is_nil(territory["armies"])

    # try to update territories when territory is not owned
    case Game.update_territory_armies(board, @territory_name, @player_one, 5) do
      {:ok, _updated_board} -> flunk("can't update armies if territory is not owned")
      {:error, message} -> assert message == :territory_not_owned
    end

    updated_board = Game.assign_territory(board, @territory_name, @player_one)

    # try to update territories when territory is owned
    case Game.update_territory_armies(updated_board, @territory_name, @player_one, 5) do
      {:ok, updated_board} ->
        {updated_territory, _index} = Game.find_territory(updated_board, @territory_name)
        assert updated_territory["armies"] == 5

      {:error, _message} ->
        flunk("should be able to update armies")
    end
  end

  test "player_owns_territory?", %{board: board} do
    # confirm no one owns territory
    {territory, _index} = Game.find_territory(board, @territory_name)
    assert is_nil(territory["owner"])

    # assign_territory
    updated_board = Game.assign_territory(board, @territory_name, @player_one)

    # confirm that field is no longer nil
    {updated_territory, _index} = Game.find_territory(updated_board, @territory_name)
    refute is_nil(updated_territory["owner"])

    # confirm API is working
    assert Game.player_owns_territory?(updated_board, @territory_name, @player_one) == true
    assert Game.player_owns_territory?(updated_board, @territory_name, @player_two) == false
  end

  test "player_territories", %{board: board} do
    board = Game.assign_territory(board, @territory_name, @player_one)
    board = Game.assign_territory(board, @territory_name_two, @player_one)

    territories = Game.player_territories(board, @player_one)

    assert length(territories) == 2

    assert List.first(territories) |> Map.get("name") == @territory_name ||
             List.first(territories) |> Map.get("name") == @territory_name_two

    assert List.last(territories) |> Map.get("name") == @territory_name ||
             List.last(territories) |> Map.get("name") == @territory_name_two
  end

  test "distribute_starting_territories", %{board: board, players: players} do
    board = Game.distribute_starting_territories(board, players)
    IO.inspect(board)
  end
end
