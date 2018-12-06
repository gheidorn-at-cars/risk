defmodule Risk.GameServerTest do
  use ExUnit.Case
  alias Risk.{Game, GameServer, Player}
  # alias Risk.Game.Territory

  @game_name "UnitTestGameServer"

  setup do
    {:ok, pid} = GameServer.start_link(@game_name)
    {:ok, game_name: @game_name, server: pid}
  end

  test "retrieve game_state", %{game_name: game_name} do
    {:ok, game} = GameServer.game_state(game_name)
    assert length(game.territories) > 0
    assert game.state == "Initialized"
    assert length(game.players) > 0
    assert !is_nil(game.turn)
    assert is_nil(game.winner)
  end

  describe "placing armies" do
    test "player place an army", %{game_name: game_name} do
      # GameServer.place_armies(game_name, player, terrtiory, 1)
      # state = GameServer.game_state(game_name)
    end
  end
end
