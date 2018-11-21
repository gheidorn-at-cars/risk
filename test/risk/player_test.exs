defmodule Risk.PlayerTest do
  use ExUnit.Case
  alias Risk.{Board, Player}

  @game_settings File.read!("priv/data/game_settings.json") |> Jason.decode!()

  @player_one %Player{
    name: "Abe Lincoln",
    armies_to_place: 5
  }
  @player_two %Player{
    name: "Winston Churchill",
    armies_to_place: 5
  }

  setup do
    %{game_settings: @game_settings, board: Board.new(), players: [@player_one, @player_two]}
  end

  test "player_armies_to_place", %{players: players} do
    assert Player.player_armies_to_place(List.first(players)) == 5
    assert Player.player_armies_to_place(List.last(players)) == 5
  end

  test "apply_game_settings", %{game_settings: game_settings, players: players} do
    players = Player.apply_game_settings(players, game_settings)

    player1 = List.first(players)
    assert player1.armies_to_place == game_settings["starting_armies"]

    player2 = List.last(players)
    assert player2.armies_to_place == game_settings["starting_armies"]
  end
end
