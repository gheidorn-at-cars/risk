defmodule Risk.Player do
  defstruct name: nil, armies_to_place: 0

  @type t :: %__MODULE__{
          name: String.t(),
          armies_to_place: integer()
        }

  @doc """
  Return the number of armies remaining to place for a given player.
  """
  @spec player_armies_to_place(Risk.Player.t()) :: integer()
  def player_armies_to_place(player) do
    player.armies_to_place
  end

  @doc """
  When a Game starts, there may be Game Settings that apply to a `Player` struct.  This function applies
  any state changes relating to Game Settings.
  """
  @spec apply_game_settings(list(Player.t()), map()) :: list(Player.t())
  def apply_game_settings(players, game_settings) do
    update_starting_armies(players, [], game_settings["starting_armies"])
  end

  @doc """
  Iterate through a list of players and set the `armies_to_place` field to a new value.
  """
  @spec update_starting_armies(list(Player.t()), list(Player.t()), integer) :: list(Player.t())
  def update_starting_armies([player | other_players], updated_players, num_armies) do
    update_starting_armies(
      other_players,
      [%{player | armies_to_place: num_armies} | updated_players],
      num_armies
    )
  end

  def update_starting_armies([], updated_players, _num_armies) do
    updated_players
  end
end
