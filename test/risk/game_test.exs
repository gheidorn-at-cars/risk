defmodule Risk.GameTest do
  use ExUnit.Case
  doctest Risk.Game
  require Logger
  alias Risk.{Game, Player}
  alias Risk.Game.Territory

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

  # @territory_name_two "Alberta"

  @territory_group_one [
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

  @territory_group_two [
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

  @player_one %Player{
    name: "Abe Lincoln",
    armies: 5
  }

  @player_two %Player{
    name: "Winston Churchill",
    armies: 5
  }

  setup do
    game = Game.new([@player_one, @player_two])
    {:ok, game: game}
  end

  test "get_territory", %{game: game} do
    case Game.get_territory(game.territories, @territory_name) do
      {territory, _index} ->
        assert territory.name == @territory_name
        assert territory.continent == @territory_continent
        assert territory.adjacent == @territory_adjacent

      nil ->
        nil
    end

    case Game.get_territory(game.territories, "Ontario123") do
      {_territory, _index} ->
        flunk("should be nil")

      nil ->
        nil
    end
  end

  test "get_player", %{game: game} do
    case Game.get_player(game.players, @player_one) do
      {player, _index} ->
        # game_settings adjust to 7
        assert player.armies == 7

      nil ->
        nil
    end

    case Game.get_player(game.players, %Player{name: "Joe123"}) do
      {_player, _index} ->
        flunk("should be nil")

      nil ->
        nil
    end

    assert is_nil(Game.get_player(game.players, "Joe123"))
  end

  test "get_player_by_turn", %{game: game} do
    {player, _index} = Game.get_player_by_turn(game)
    assert player.name == game.turn
  end

  test "assign_territory", %{game: game} do
    # assign_territory
    territories = Game.assign_territory(game.territories, @territory_name, @player_one)

    # confirm the territory was updated on the board
    {territory, _index} = Game.get_territory(territories, @territory_name)
    assert territory.owner == @player_one.name
  end

  test "assign_territories", %{game: game} do
    player1 = List.first(game.players)
    territories = Game.assign_territories(game.territories, @territory_group_one, player1)
    {alaska, _index} = Game.get_territory(territories, "Alaska")
    {alberta, _index} = Game.get_territory(territories, "Alberta")

    assert alaska.owner == player1.name
    assert alberta.owner == player1.name

    player2 = List.last(game.players)
    territories = Game.assign_territories(territories, @territory_group_two, player2)
    {venezuela, _index} = Game.get_territory(territories, "Venezuela")
    {brazil, _index} = Game.get_territory(territories, "Brazil")

    assert venezuela.owner == player2.name
    assert brazil.owner == player2.name
  end

  test "update_territory_armies", %{game: game} do
    # confirm that no armies exist on a new board
    for t <- game.territories, do: assert(t.armies == 0)

    player_one_enemy_territories = Game.enemy_territories(game.territories, @player_one)
    enemy_territory = List.first(player_one_enemy_territories)

    # try to update territories when territory is not owned
    case Game.update_territory_armies(game.territories, enemy_territory.name, @player_one, 5) do
      {:ok, _territories} -> flunk("can't update armies if territory is not owned")
      {:error, message} -> assert message == :territory_not_owned
    end

    player_one_territories = Game.player_territories(game.territories, @player_one)
    player_territory = List.first(player_one_territories)

    # try to update territories when territory is owned
    case Game.update_territory_armies(game.territories, player_territory.name, @player_one, 5001) do
      {:ok, territories} ->
        case Game.get_territory(territories, player_territory.name) do
          {territory, _index} ->
            assert territory.armies == 5001

          nil ->
            flunk("territory should exist")
        end

      {:error, _message} ->
        flunk("should be able to update armies")
    end
  end

  test "player_owns_territory?", %{game: game} do
    # assign_territory
    territories = Game.assign_territory(game.territories, @territory_name, @player_one)

    # confirm that field is no longer nil
    {territory, _index} = Game.get_territory(territories, @territory_name)
    refute is_nil(territory.owner)

    # confirm API is working
    assert Game.player_owns_territory?(territories, @territory_name, @player_one) == true
    assert Game.player_owns_territory?(territories, @territory_name, @player_two) == false
  end

  test "player_territories", %{game: game} do
    territories = Game.player_territories(game.territories, @player_one)
    assert length(territories) == 3
    for t <- territories, do: assert(t.owner == @player_one.name)
  end

  test "distribute_starting_territories", %{game: game} do
    territories = Game.distribute_starting_territories(game.territories, game.players)
    assert length(Game.player_territories(territories, List.first(game.players))) > 0
    assert length(Game.player_territories(territories, List.last(game.players))) > 0
  end

  test "place_armies", %{game: game} do
    # get the territories for a player
    player1 = List.first(game.players)
    player_one_territories = Game.player_territories(game.territories, player1)

    territory_to_place_army_on = List.first(player_one_territories)

    {:ok, game} = Game.place_armies(game, territory_to_place_army_on.name, player1, 1)
    # IO.inspect(game)

    {territory, _index} = Game.get_territory(game.territories, territory_to_place_army_on.name)
    assert territory.armies == 1

    {player, _index} = Game.get_player(game.players, player1.name)
    assert player.armies == 6
  end

  test "advance_turn", %{game: game} do
    # get the current turn
    turn1 = game.turn
    Logger.debug("turn1 => #{turn1}")

    {turn2, game} = Game.advance_turn(game)
    Logger.debug("turn2 => #{turn2}")
    Logger.debug("game.turn => #{game.turn}")

    # check if turn was advanced to next player
    refute is_nil(turn2)
    refute turn1 == turn2
    refute turn1 == game.turn

    {turn3, game} = Game.advance_turn(game)
    Logger.debug("turn3 => #{turn3}")
    Logger.debug("game.turn => #{game.turn}")

    # check if turn was advanced to next player
    refute is_nil(turn3)
    refute turn2 == turn3
    refute turn2 == game.turn
  end
end
