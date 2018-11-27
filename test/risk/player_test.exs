defmodule Risk.PlayerTest do
  use ExUnit.Case
  alias Risk.{Game, Player}

  @game_settings File.read!("priv/data/game_settings.json") |> Jason.decode!()

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

  test "apply_game_settings", %{game: game} do
    players = Player.apply_game_settings(game.players, game.game_settings)

    player1 = List.first(players)
    assert player1.armies == game.game_settings["starting_armies"]

    player2 = List.last(players)
    assert player2.armies == game.game_settings["starting_armies"]
  end
end
