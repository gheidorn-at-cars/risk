defmodule Risk.GameStateTest do
  use ExUnit.Case, async: true

  alias Risk.{Repo, GameState}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "game_states" do
    @initial_game_settings %{
      "starting_armies" => 7
    }

    @player_one %{
      "name" => "Abe Lincoln",
      "armies" => 5
    }

    @player_two %{
      "name" => "Winston Churchill",
      "armies" => 5
    }

    @initial_territories [
      %{
        "adjacent" => ["Central America", "Peru", "Brazil"],
        "armies" => 0,
        "continent" => "South America",
        "name" => "Venezuela",
        "owner" => "Player 2"
      },
      %{
        "adjacent" => [
          "Alaska",
          "Northwest Territory",
          "Western United States",
          "Ontario",
          "Greenland"
        ],
        "armies" => 0,
        "continent" => "North America",
        "name" => "Alberta",
        "owner" => "Player 1"
      }
    ]

    @valid_new_attrs %{
      "name" => "Quick Rematch",
      "state" => "Initialized",
      "turn" => "Player1",
      "winner" => nil,
      "players" => [@player_one, @player_two],
      "turn_order" => ["Player1", "Player2"],
      "game_settings" => @initial_game_settings,
      "territories" => @initial_territories
    }
  end

  def game_state_fixture(attrs \\ %{}) do
    {:ok, game_state} =
      attrs
      |> Enum.into(@valid_new_attrs)
      |> GameState.create()

    game_state
  end

  test "list_game_states/0 returns all game states" do
    game_state = game_state_fixture()
    assert Risk.GameState.list_game_states() == [game_state]
  end

  test "create_game_state/1 with valid data creates a game_state" do
    assert {:ok, %GameState{} = game_state} = GameState.create(@valid_new_attrs)
    assert game_state.name == @valid_new_attrs["name"]
    assert game_state.state == @valid_new_attrs["state"]
    assert game_state.turn == @valid_new_attrs["turn"]
    assert game_state.winner == @valid_new_attrs["winner"]
    assert game_state.players == @valid_new_attrs["players"]
    assert game_state.turn_order == @valid_new_attrs["turn_order"]
    assert game_state.game_settings == @valid_new_attrs["game_settings"]
    assert game_state.territories == @valid_new_attrs["territories"]
  end
end
