defmodule Risk.Game.WorldServer do
  use ExUnit.Case, async: true

  # setup do
  #   world_server = start_supervised!(Risk.Game.WorldServer)
  #   %{world_server: world_server}
  # end

  # test "game fails to start without 2 players", %{world_server: world_server} do
  #   assert Risk.Game.WorldServer.start_game(world_server, []) == :invalid_start_players
  # end

  # test "game starts successfully with 2 players", %{world_server: world_server} do
  #   assert Risk.Game.WorldServer.start_game(world_server, ["player1", "player2"]) == :success
  # end
end
