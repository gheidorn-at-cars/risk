defmodule Risk.GameSimulationTest do
  use ExUnit.Case
  doctest Risk.Game
  require Logger
  alias Risk.{Game, Player}

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

  test "game_start_with_army_placement", %{game: game} do
    # Logger.debug("#{inspect(territory_to_place.name)}")
    # Logger.debug("#{inspect(current_player)}")

    # after a game is started, it should be in the :initialized state
    assert game.state == :initialized

    # placement player 1 turn 1
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 2 turn 1
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 1 turn 2
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 2 turn 2
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 1 turn 3
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 2 turn 3
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 1 turn 4
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 2 turn 4
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 1 turn 5
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 2 turn 5
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 1 turn 6
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 2 turn 6
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 1 turn 7
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 2 turn 7
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)
    {:ok, game} = Game.place_armies(game, territory_to_place.name, current_player, 1)
    {_next_player, game} = Game.advance_turn(game)

    # placement player 1 turn 7
    {current_player, _index} = Game.get_player_by_turn(game)
    current_player_territories = Game.player_territories(game.territories, current_player)
    territory_to_place = Enum.random(current_player_territories)

    case Game.place_armies(game, territory_to_place.name, current_player, 1) do
      {:ok, _game} ->
        flunk("player should not have enough armies")

      # {_next_player, game} = Game.advance_turn(game)
      {:error, message} ->
        assert message == :not_enough_armies
        # IO.inspect(game)
    end
  end
end
